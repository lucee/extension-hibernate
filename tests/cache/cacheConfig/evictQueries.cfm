<cfscript>
// ormEvictQueries clears query cache
transaction {
	entity = entityNew( "CacheItem" );
	entity.setId( createUUID() );
	entity.setName( "evict-test" );
	entitySave( entity );
	ormFlush();
}

// populate query cache
ormExecuteQuery( "FROM CacheItem WHERE name = :n", { n: "evict-test" }, false, { cacheable: true } );

// delete from DB
queryExecute( "DELETE FROM CacheItem WHERE id = :id", { id: entity.getId() }, { datasource: "h2" } );

// evict query cache
ormEvictQueries();
ormClearSession();

// after evict, query should hit DB and find nothing
result = ormExecuteQuery( "FROM CacheItem WHERE name = :n", { n: "evict-test" }, false, { cacheable: true } );
if ( arrayLen( result ) != 0 )
	throw( message="evictQueries: expected 0 after evict, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
