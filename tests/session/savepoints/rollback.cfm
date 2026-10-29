<cfscript>
	ormReload();
	transaction {
		entitySave( entityNew( "Auto", { "make": "A", "model": "A", "id": createUUID() } ) );
		transactionSetSavepoint( "sp1" );
		entitySave( entityNew( "Auto", { "make": "B", "model": "B", "id": createUUID() } ) );
		transactionRollback( "sp1" );
		entitySave( entityNew( "Auto", { "make": "C", "model": "C", "id": createUUID() } ) );
		transactionCommit();
	}
	makes = valueList( queryExecute( "SELECT make FROM Auto ORDER BY make", {}, { datasource: "h2" } ).make );
	if ( makes != "A,C" ) throw "expected A,C, found #makes#";
	echo( "ok" );
</cfscript>
