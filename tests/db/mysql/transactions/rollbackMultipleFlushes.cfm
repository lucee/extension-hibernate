<cfscript>
// LDEV-966 regression: rollback must revert ALL flushed ORM changes, even across
// multiple ormFlush() calls within the same transaction.
// This is the critical test for verifying the SERIALIZABLE removal is safe — the original
// LDEV-966 fix was about autoCommit, not isolation.

id1 = createUUID();
id2 = createUUID();
id3 = createUUID();

transaction {
	entitySave( entityNew( "Auto", { id: id1, make: "Audi", model: "A4" } ) );
	ormFlush();

	entitySave( entityNew( "Auto", { id: id2, make: "Audi", model: "A6" } ) );
	ormFlush();

	entitySave( entityNew( "Auto", { id: id3, make: "Audi", model: "A8" } ) );
	ormFlush();

	// all three flushed — verify they're visible within the transaction
	midCheck = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE make = :make", { make: "Audi" } );
	if ( midCheck.cnt != 3 )
		throw( message="expected 3 Audi rows mid-transaction, got #midCheck.cnt#" );

	transactionRollback();
}

// after rollback — all three should be gone
result = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE make = :make", { make: "Audi" } );
if ( result.cnt != 0 )
	throw( message="expected 0 Audi rows after rollback of 3 flushes, got #result.cnt#" );

echo( "ok" );
</cfscript>
