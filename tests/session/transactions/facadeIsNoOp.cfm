<cfscript>
// LDEV-6206: Document and verify that HibernateORMTransaction is currently a no-op facade.
//
// This test captures the CURRENT (broken) behaviour as a baseline. When the new major
// version fixes the facade, some of these assertions will flip — that's expected and the
// test should be updated to match the new correct behaviour.
//
// Current behaviour:
// - commit() does nothing — data survives only because of implicit JDBC commit via setAutoCommit(true)
// - rollback() flags doRollback but the Hibernate transaction was never begun
// - There is no real Hibernate transaction wrapping ORM operations

// ---- Test 1: transactionCommit() is a no-op for ORM ----
// Data should still persist because of the implicit JDBC commit in end(),
// not because transactionCommit() does anything.
id1 = createUUID();
transaction {
	entitySave( entityNew( "Auto", { id: id1, make: "Tesla", model: "S" } ) );
	transactionCommit();
	// after commit, save another entity — in a real transaction this would start a new tx
	// but since commit() is a no-op, this is just another save in the same session
	entitySave( entityNew( "Auto", { id: createUUID(), make: "Tesla", model: "3" } ) );
}

r1 = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE make = :make", { make: "Tesla" } );
// both should exist — the "commit" didn't actually separate them into different transactions
if ( r1.cnt != 2 )
	throw( message="expected 2 Tesla rows (facade no-op), got #r1.cnt#" );

// ---- Test 2: multiple entitySave without explicit flush — all commit at end ----
id2 = createUUID();
id3 = createUUID();
transaction {
	entitySave( entityNew( "Auto", { id: id2, make: "Porsche", model: "911" } ) );
	entitySave( entityNew( "Auto", { id: id3, make: "Porsche", model: "Cayenne" } ) );
	// no flush, no commit — end() flushes the session
}

r2 = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE make = :make", { make: "Porsche" } );
if ( r2.cnt != 2 )
	throw( message="expected 2 Porsche rows after implicit end(), got #r2.cnt#" );

// ---- Test 3: verify isWithinTransaction() inside a transaction block ----
wasInTx = false;
transaction {
	wasInTx = isWithinTransaction();
}
// isWithinTransaction() checks core's autoCommit flag — should be true inside transaction{}
if ( !wasInTx )
	throw( message="isWithinTransaction() returned false inside transaction block" );

echo( "ok" );
</cfscript>
