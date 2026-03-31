<cfscript>
// entity names should be case-insensitive — "auto" should work for "Auto"
auto = entityNew( "auto" );
auto.setId( createUUID() );
auto.setMake( "Toyota" );
entitySave( auto );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM Auto" );
if ( result.cnt[ 1 ] != 1 )
	throw( message="wrong case: expected 1 row, got #result.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
