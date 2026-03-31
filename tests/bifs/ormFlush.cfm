<cfscript>
// ormFlush with no datasource arg
auto = entityNew( "Auto", { id: createUUID(), make: "Toyota" } );
entitySave( auto );
ormFlush();
result = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE id = :id", { id: auto.getId() } );
if ( result.cnt[ 1 ] != 1 ) throw( message="ormFlush: expected 1 row, got #result.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
