<cfscript>
	ormReload();

	failed = false;
	try {
		transaction {
			item = entityNew( "Item" );
			item.setName( repeatString( "x", 100 ) );
			entitySave( item );
		}
	}
	catch ( any e ) {
		failed = true;
		if ( findNoCase( "already active", e.message ) ) rethrow;
	}
	if ( !failed ) throw( message="expected the oversized insert to fail the flush" );

	transaction {
		ok = entityNew( "Item" );
		ok.setName( "ok" );
		entitySave( ok );
	}

	rows = queryExecute( "SELECT name FROM ldev6935_item" );
	if ( rows.recordCount != 1 ) throw( message="expected 1 persisted row after the second transaction, got #rows.recordCount#" );
	if ( rows.name != "ok" ) throw( message="expected the valid row to be persisted, got #rows.name#" );

	echo( "ok" );
</cfscript>
