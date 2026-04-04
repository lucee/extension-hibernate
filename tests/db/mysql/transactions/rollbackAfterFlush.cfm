<cfscript>
// LDEV-966 regression: rollback must revert ORM changes even after ormFlush().
// The original LDEV-966 fix was about autoCommit management. The forced SERIALIZABLE
// in _add() was cargo-culted in and is NOT needed for rollback to work.
// This test verifies rollback works regardless of isolation level.

id = createUUID();

transaction {
	auto = entityNew( "Auto", { id: id, make: "BMW", model: "M3" } );
	entitySave( auto );
	ormFlush();

	// data is flushed to the DB — but we're in a transaction, so rollback should revert it
	midCheck = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
	// flushed data should be visible within the transaction
	if ( midCheck.recordCount != 1 )
		throw( message="expected 1 row after flush (within tx), got #midCheck.recordCount#" );

	transactionRollback();
}

// after rollback, data should be gone
result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 0 )
	throw( message="expected 0 rows after rollback, got #result.recordCount#" );

echo( "ok" );
</cfscript>
