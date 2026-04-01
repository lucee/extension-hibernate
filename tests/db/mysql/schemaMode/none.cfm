<cfscript>
// dbcreate=none: ORM should NOT create or modify schema
// pre-create the table manually, then use ORM against it
try {
	queryExecute( "CREATE TABLE Item ( id VARCHAR(255) PRIMARY KEY, name VARCHAR(255) )" );
} catch ( any e ) {
	// table may already exist — that's fine for dbcreate=none
	queryExecute( "DELETE FROM Item" );
}

id = createUUID();
item = entityNew( "Item", { id: id, name: "widget" } );
entitySave( item );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM Item WHERE id = :id", { id: id } );
if ( result.cnt[ 1 ] != 1 )
	throw( message="none: expected 1 row, got #result.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
