<cfscript>
// Test: exception mid-transaction should not leave partial commits.
// Currently, since the facade is a no-op, the session flush in end() may or may not
// persist data depending on the Hibernate session state after an error.
//
// This test documents the current behaviour for comparison after LDEV-6206.

id1 = createUUID();
id2 = createUUID();

try {
	transaction {
		entitySave( entityNew( "Auto", { id: id1, make: "Lexus", model: "IS" } ) );
		ormFlush();

		entitySave( entityNew( "Auto", { id: id2, make: "Lexus", model: "GS" } ) );
		ormFlush();

		throw( message="deliberate error mid-transaction" );
	}
} catch ( any e ) {
	// transaction should have ended via doFinally
	if ( e.message != "deliberate error mid-transaction" ) rethrow;
}

// After an exception, the transaction block calls end() which calls rollback
// (doFinally sets doRollback when an exception occurred)
r1 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id1 } );
r2 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id2 } );

// Both should be gone — the exception triggers rollback path in Transaction.doFinally()
if ( r1.recordCount != 0 )
	throw( message="expected 0 rows for Lexus IS after exception, got #r1.recordCount#" );
if ( r2.recordCount != 0 )
	throw( message="expected 0 rows for Lexus GS after exception, got #r2.recordCount#" );

echo( "ok" );
</cfscript>
