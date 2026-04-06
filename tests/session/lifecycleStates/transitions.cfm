<cfscript>
ormSess = ORMGetSession();

// 1. TRANSIENT — entityNew creates a transient instance (not in session)
entity = entityNew( "StateEntity", { id: createUUID(), name: "Transient" } );
if ( ormSess.contains( entity ) )
	throw( message="new entity should be transient (not in session)" );

// 2. PERSISTENT — entitySave attaches it to the session
entitySave( entity );
if ( !ormSess.contains( entity ) )
	throw( message="saved entity should be persistent (in session)" );

ormFlush();

// 3. DETACHED — ormClearSession detaches all entities
ormClearSession();
ormSess = ORMGetSession();
if ( ormSess.contains( entity ) )
	throw( message="entity should be detached after clearSession" );

// 4. RE-ATTACHED — entityMerge brings it back
merged = entityMerge( entity );
ormSess = ORMGetSession();
if ( !ormSess.contains( merged ) )
	throw( message="merged entity should be persistent again" );

// 5. REMOVED — entityDelete marks it for removal
entityDelete( merged );
ormFlush();
ormClearSession();

// verify it's gone from DB
row = queryExecute( "SELECT count(*) as cnt FROM LC_Entity WHERE id = :id", { id: entity.getId() } );
if ( row.cnt != 0 )
	throw( message="deleted entity should be gone from DB" );

echo( "ok" );
</cfscript>
