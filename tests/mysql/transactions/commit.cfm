<cfscript>
id = createUUID();
transaction {
	auto = entityNew( "Auto", { id: id, make: "Toyota", model: "Camry" } );
	entitySave( auto );
	transactionCommit();
}
result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 ) throw( message="expected 1 row after commit, got #result.recordCount#" );

echo( "ok" );
</cfscript>
