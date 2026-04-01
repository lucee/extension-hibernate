<cfscript>
// dropcreate: schema created automatically, save works
item = entityNew( "Item", { id: createUUID(), name: "test" } );
entitySave( item );
ormFlush();

// verify via direct SQL
result = queryExecute( "SELECT count(*) as cnt FROM Item" );
if ( result.cnt[ 1 ] != 1 ) throw( message="dropcreate: expected 1 row, got #result.cnt[ 1 ]#" );

// dropcreate means second request gets clean schema — verify by counting
// (within same request, table should only have our row)
item2 = entityNew( "Item", { id: createUUID(), name: "test2" } );
entitySave( item2 );
ormFlush();
result2 = queryExecute( "SELECT count(*) as cnt FROM Item" );
if ( result2.cnt[ 1 ] != 2 ) throw( message="dropcreate: expected 2 rows in same request, got #result2.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
