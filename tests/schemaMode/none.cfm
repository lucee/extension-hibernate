<cfscript>
// dbcreate=none: ORM should NOT create or modify schema
// pre-create the table manually, then use ORM against it
queryExecute( "
	CREATE TABLE IF NOT EXISTS Item (
		id VARCHAR(255) PRIMARY KEY,
		name VARCHAR(255)
	)
" );

item = entityNew( "Item", { id: createUUID(), name: "widget" } );
entitySave( item );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM Item" );
if ( result.cnt[ 1 ] != 1 )
	throw( message="none: expected 1 row, got #result.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
