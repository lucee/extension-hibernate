<cfscript>
// ormClearSession → loadByPK loads fresh from DB
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "cached" );
entitySave( entity );
ormFlush();

// update directly in DB
queryExecute( "UPDATE SmokeEntity SET name = 'db-direct' WHERE id = :id", { id: entity.getId() } );

// without clear, would still get cached version
ormClearSession();
loaded = entityLoadByPK( "SmokeEntity", entity.getId() );
if ( loaded.getName() != "db-direct" )
	throw( message="clearSession: expected db-direct, got [#loaded.getName()#]" );
echo( "ok" );
</cfscript>
