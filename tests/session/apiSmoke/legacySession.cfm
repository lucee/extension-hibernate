<cfscript>
// Locks down the H5.6-era Session legacy-method contract for the 8 mechanical
// families per h73-session-shim-spec.md. On 5.6 these are native Session
// methods; on 7.0+ they're re-exposed by CompatSessionWrapper routing to H7
// JPA equivalents (persist/merge/remove/getReference/createNativeQuery/etc.).
// Same test must pass on both branches — that's the contract.
//
// Empirical surface verified via tests/compat/sessionApiSurface/. Common forms
// covered here; overloads (entity-name, LockMode/LockOptions variants) are
// implemented in the wrapper and exercised through InvocationHandler dispatch
// from this same probe.

sess = ormGetSession();

// SmokeEntity uses string ids with no generator — the H5 save() / saveOrUpdate()
// contract on this entity has always required the caller assign the id before
// save. H7's persist() enforces the same. Our wrapper preserves the H5 shape
// (returns the assigned id from save()).

// 1) save(entity) → persist + return id (H5 contract).
e1 = entityNew( "SmokeEntity" );
e1.setId( createUUID() );
e1.setName( "save-test" );
id1 = sess.save( e1 );
ormFlush();
if ( isNull( id1 ) )
	throw( message="save: returned null id" );
if ( id1 != e1.getId() )
	throw( message="save: returned id [#id1#] doesn't match assigned id [#e1.getId()#]" );
loaded1 = entityLoadByPK( "SmokeEntity", id1 );
if ( isNull( loaded1 ) || loaded1.getName() != "save-test" )
	throw( message="save: entity not persisted, loaded=[#serializeJSON( loaded1 )#]" );

// 2) update(entity) → merge.
loaded1.setName( "updated" );
sess.update( loaded1 );
ormFlush();
reloaded1 = entityLoadByPK( "SmokeEntity", id1 );
if ( reloaded1.getName() != "updated" )
	throw( message="update: merge didn't apply, name=[#reloaded1.getName()#]" );

// 3) saveOrUpdate(new) → persist when entity has no managed id.
e2 = entityNew( "SmokeEntity" );
e2.setId( createUUID() );
e2.setName( "saveOrUpdate-new" );
sess.saveOrUpdate( e2 );
ormFlush();
id2 = e2.getId();

// 4) saveOrUpdate(existing) → merge when entity is in the persistence context.
e2.setName( "saveOrUpdate-modified" );
sess.saveOrUpdate( e2 );
ormFlush();
reloaded2 = entityLoadByPK( "SmokeEntity", id2 );
if ( reloaded2.getName() != "saveOrUpdate-modified" )
	throw( message="saveOrUpdate(existing): change not flushed, name=[#reloaded2.getName()#]" );

// 5) delete(entity) → remove.
sess.delete( reloaded2 );
ormFlush();
gone = entityLoadByPK( "SmokeEntity", id2 );
if ( !isNull( gone ) )
	throw( message="delete: entity still present after flush" );

// 6) load(...) — NOT shimmed. Verified zero CFML callers via gh search code
//    (2026-04-29). H7's load(Object existingInstance, Object id) still ships
//    with void return, which interferes with Lucee dispatch when sibling
//    overloads share the same arity. Callers wanting "load by name" semantics
//    should use getReference directly.

// 7) createSQLQuery(sql) → createNativeQuery. Verify it returns a Query
//    object that can run.
nativeQ = sess.createSQLQuery( "SELECT id FROM SmokeEntity" );
if ( isNull( nativeQ ) )
	throw( message="createSQLQuery: returned null" );
results = nativeQ.list();
if ( !isArray( results ) )
	throw( message="createSQLQuery: list() should return array, got [#serializeJSON( results )#]" );

// 8) getNamedSQLQuery — tested only if a named query is defined on the SF.
//    SmokeEntity doesn't declare one, so we just verify the method exists by
//    catching whatever Hibernate throws for an unknown query name. Either way,
//    the method must resolve through the wrapper without "method not found".
methodResolved = false;
try {
	sess.getNamedSQLQuery( "nonexistent-named-query" );
	methodResolved = true;
} catch ( any e ) {
	// Hibernate throws IllegalArgumentException or HibernateException for
	// unknown names — anything is fine. What we care about is that the method
	// resolved through the wrapper rather than NoSuchMethodException.
	if ( findNoCase( "No matching method", e.message ) )
		throw( message="getNamedSQLQuery: not exposed by wrapper, [#e.message#]" );
	methodResolved = true;
}
if ( !methodResolved )
	throw( message="getNamedSQLQuery: did not resolve through wrapper" );

echo( "ok" );
</cfscript>
