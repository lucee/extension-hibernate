<cfscript>
// dbcreate=update: ORM should create missing tables (not drop existing)
// just verify the table exists and we can save
item = entityNew( "Item", { id: createUUID(), name: "gadget" } );
entitySave( item );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM Item" );
if ( result.cnt[ 1 ] < 1 )
	throw( message="update: expected at least 1 row, got #result.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
