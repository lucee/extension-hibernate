<cfscript>
// With flushAtRequestEnd=false, must explicitly call ormFlush to persist
id = createUUID();
auto = entityNew( "Auto", { id: id, make: "Visible" } );
entitySave( auto );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE id = :id", { id: id } );
if ( result.cnt[ 1 ] != 1 ) throw( message="explicit flush: expected 1, got #result.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
