<cfscript>
// verify transaction with isolation="read_committed" works
id = createUUID();
transaction isolation="read_committed" {
	auto = entityNew( "Auto", { id: id, make: "Subaru", model: "WRX" } );
	entitySave( auto );
	ormFlush();
	transactionCommit();
}

result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 )
	throw( message="read_committed: expected 1 row, got #result.recordCount#" );

// also verify rollback works with isolation level
id2 = createUUID();
transaction isolation="read_committed" {
	auto2 = entityNew( "Auto", { id: id2, make: "Mazda", model: "3" } );
	entitySave( auto2 );
	transactionRollback();
}

result2 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id2 } );
if ( result2.recordCount != 0 )
	throw( message="read_committed rollback: expected 0 rows, got #result2.recordCount#" );

echo( "ok" );
</cfscript>
