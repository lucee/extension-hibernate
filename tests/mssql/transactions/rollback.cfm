<cfscript>
id = createUUID();
transaction {
	auto = entityNew( "Auto", { id: id, make: "Hyundai", model: "Elantra" } );
	entitySave( auto );
	transactionRollback();
}
result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 0 ) throw( message="expected 0 rows after rollback, got #result.recordCount#" );

echo( "ok" );
</cfscript>
