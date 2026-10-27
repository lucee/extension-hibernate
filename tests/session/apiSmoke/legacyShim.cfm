<cfscript>
// Locks down the H5.6 SessionFactory metadata API surface that real-world CFML
// code (cborm, ColdBox BaseORMService, Slatwall, basecfc, ModelGlue, ColdMVC)
// depends on. On 5.6 these are native methods; on 7.0+ they're provided by the
// compat shim wrapping the H7 SessionFactoryImplementor returned to CFML.
// Same test must pass on both branches — that's the contract.
sf = ORMGetSessionFactory();

// 1) getDialect()
dialect = sf.getDialect();
if ( isNull( dialect ) )
	throw( message="getDialect: returned null" );
dialectClass = dialect.getClass().getName();
if ( dialectClass does not contain "Dialect" )
	throw( message="getDialect: expected class name to contain 'Dialect', got [#dialectClass#]" );
if ( dialectClass does not contain "H2" )
	throw( message="getDialect: expected H2 dialect, got [#dialectClass#]" );

// 2) getClassMetadata( name ) — entity introspection
md = sf.getClassMetadata( "SmokeEntity" );
if ( isNull( md ) )
	throw( message="getClassMetadata: returned null for SmokeEntity" );
propNames = md.getPropertyNames();
if ( !isArray( propNames ) || arrayLen( propNames ) == 0 )
	throw( message="getClassMetadata: expected non-empty property names, got [#serializeJSON( propNames )#]" );
if ( !arrayContainsNoCase( propNames, "name" ) )
	throw( message="getClassMetadata: expected 'name' in property names, got [#arrayToList( propNames )#]" );
idName = md.getIdentifierPropertyName();
if ( idName != "id" )
	throw( message="getClassMetadata: expected identifier property 'id', got [#idName#]" );
entityName = md.getEntityName();
if ( entityName != "SmokeEntity" )
	throw( message="getClassMetadata: expected entity name 'SmokeEntity', got [#entityName#]" );

// Note: getAllClassMetadata() intentionally NOT covered. Hibernate 5.6.15's own
// SessionFactoryImpl.getAllClassMetadata() throws UnsupportedOperationException
// ("org.hibernate.SessionFactory.getAllClassMetadata is no longer supported"),
// so there's nothing on 5.6 for the H7 shim to keep working. Any caller that
// still references it has been broken upstream for years.

// 3) getCollectionMetadata( role ) — H5.6 throws MappingException for unknown role
// (not null, as H7's findCollectionDescriptor Javadoc would suggest). The shim
// must match this contract: translate findCollectionDescriptor's null-return into
// a MappingException with the same "Could not locate CollectionPersister" message.
threwForUnknown = false;
errMsg = "";
try {
	sf.getCollectionMetadata( "SmokeEntity.nonexistent" );
} catch ( any e ) {
	threwForUnknown = true;
	errMsg = e.message;
}
if ( !threwForUnknown )
	throw( message="getCollectionMetadata: expected throw for unknown role, got no exception" );
if ( !findNoCase( "CollectionPersister", errMsg ) && !findNoCase( "could not locate", errMsg ) )
	throw( message="getCollectionMetadata: expected exception about missing CollectionPersister, got [#errMsg#]" );

// 4) getEntityPersister( name ) — H5 alias for the same lookup as getClassMetadata.
// Used by cborm SQLHelper / ORMUtilSupport and ColdBox legacy ORM helpers in the
// wild (verified via gh search code 2026-04-29). H5.6.15 throws MappingException
// for unknown names, same as getCollectionMetadata; shim must preserve that.
ep = sf.getEntityPersister( "SmokeEntity" );
if ( isNull( ep ) )
	throw( message="getEntityPersister: returned null for SmokeEntity" );
epIdName = ep.getIdentifierPropertyName();
if ( epIdName != "id" )
	throw( message="getEntityPersister: expected identifier property 'id', got [#epIdName#]" );
epEntityName = ep.getEntityName();
if ( epEntityName != "SmokeEntity" )
	throw( message="getEntityPersister: expected entity name 'SmokeEntity', got [#epEntityName#]" );

threwForUnknownEntity = false;
errMsg = "";
try {
	sf.getEntityPersister( "Nonexistent" );
} catch ( any e ) {
	threwForUnknownEntity = true;
	errMsg = e.message;
}
if ( !threwForUnknownEntity )
	throw( message="getEntityPersister: expected throw for unknown entity, got no exception" );
if ( !findNoCase( "Unknown entity", errMsg ) && !findNoCase( "EntityPersister", errMsg ) )
	throw( message="getEntityPersister: expected exception mentioning unknown entity, got [#errMsg#]" );

echo( "ok" );
</cfscript>
