<cfscript>
// query cache — two identical cacheable queries, second should use cache
// we verify by running the same query twice and ensuring both return results
transaction {
	entity = entityNew( "CacheItem" );
	entity.setId( createUUID() );
	entity.setName( "query-cache-test" );
	entitySave( entity );
	ormFlush();
}

// run cacheable query
result1 = ormExecuteQuery( "FROM CacheItem WHERE name = :n", { n: "query-cache-test" }, false, { cacheable: true } );
if ( arrayLen( result1 ) != 1 )
	throw( message="queryCacheable: first query expected 1, got #arrayLen( result1 )#" );

// run same cacheable query again — should hit query cache
result2 = ormExecuteQuery( "FROM CacheItem WHERE name = :n", { n: "query-cache-test" }, false, { cacheable: true } );
if ( arrayLen( result2 ) != 1 )
	throw( message="queryCacheable: second query expected 1, got #arrayLen( result2 )#" );
echo( "ok" );
</cfscript>
