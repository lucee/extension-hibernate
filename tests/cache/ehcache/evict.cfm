<cfscript>
// cleanup
queryExecute( "DELETE FROM Auto", {}, { datasource: "h2" } );

// save an entity — it'll be cached in L2
id = createUUID();
transaction {
	car = entityNew( "Auto" );
	car.setId( id );
	car.setMake( "Toyota" );
	car.setModel( "Supra" );
	entitySave( car );
	ormFlush();
}

// verify ormEvictEntity runs without error
ormEvictEntity( "Auto" );
ormClearSession();

// entity should still be loadable from DB after eviction
loaded = entityLoad( "Auto", id );
if ( isNull( loaded ) )
	throw( message="entity should still be loadable from DB after cache eviction" );
if ( loaded.getMake() != "Toyota" )
	throw( message="expected Toyota, got #loaded.getMake()#" );

// verify ormEvictQueries runs without error
ormEvictQueries();

echo( "ok" );
</cfscript>
