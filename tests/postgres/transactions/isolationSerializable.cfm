<cfscript>
// verify transaction with isolation="serializable" works
id = createUUID();
transaction isolation="serializable" {
	auto = entityNew( "Auto", { id: id, make: "Honda", model: "Civic" } );
	entitySave( auto );
	ormFlush();
	transactionCommit();
}

result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 )
	throw( message="serializable: expected 1 row, got #result.recordCount#" );

echo( "ok" );
</cfscript>
