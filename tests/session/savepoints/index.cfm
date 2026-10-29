<cfscript>
	ormReload();
	transaction {
		myEntity = entityNew( "Auto", {
			"make" : "Hyundai",
			"model" : "Accent",
			"id" : createUUID()
		} );

		entitySave( myEntity );
		transactionSetSavepoint();
		transactionSetSavepoint( "named" );
	}
	count = queryExecute( "SELECT id FROM Auto", {}, { datasource: "h2" } ).recordCount;
	if ( count != 1 ) throw "expected 1 row, found #count#";
	echo( "ok" );
</cfscript>
