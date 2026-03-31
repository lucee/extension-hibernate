<cfscript>
// With flushAtRequestEnd=false, entitySave without ormFlush should NOT persist
id = createUUID();
auto = entityNew( "Auto", { id: id, make: "Ghost" } );
entitySave( auto );
// deliberately NOT calling ormFlush()

// check via direct SQL — should not be in DB yet
result = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE id = :id", { id: id } );
echo( "rows=#result.cnt[ 1 ]#" );
</cfscript>
