<cfscript>
id1 = createUUID();
id2 = createUUID();

transaction {
	entitySave( entityNew( "Auto", { id: id1, make: "Toyota" } ) );
	ormFlush();

	// nested try — inner error doesn't prevent outer commit
	try {
		entitySave( entityNew( "Auto", { id: id2, make: "Ford" } ) );
		ormFlush();
		throw( message="force error" );
	} catch ( any e ) {
		// swallow — but the Ford was already flushed
	}

	transactionRollback();
}

// both should be rolled back
r1 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id1 } );
r2 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id2 } );
if ( r1.recordCount != 0 ) throw( message="expected 0 rows for Toyota after rollback, got #r1.recordCount#" );
if ( r2.recordCount != 0 ) throw( message="expected 0 rows for Ford after rollback, got #r2.recordCount#" );

echo( "ok" );
</cfscript>
