<cfscript>
// Test the interaction between transactionCommit() and transactionRollback() with ORM.
//
// Current facade behaviour: even though HibernateORMTransaction.commit() is empty,
// the Lucee core Transaction tag's commit path calls setAutoCommit(true) on the
// ORMConnection, which triggers HibernateORMTransaction.end() → session.flush().
// The JDBC setAutoCommit(true) then implicitly commits the flushed data.
//
// So transactionCommit() DOES persist ORM data — not because the facade works,
// but because of the JDBC implicit commit side-effect.
//
// After the facade fix (LDEV-6206), commit() will explicitly commit via Hibernate.
// The end result should be the same: committed data stays, rolled-back data reverts.

id1 = createUUID();
id2 = createUUID();

transaction {
	entitySave( entityNew( "Auto", { id: id1, make: "Volvo", model: "XC90" } ) );
	ormFlush();
	transactionCommit();

	entitySave( entityNew( "Auto", { id: id2, make: "Volvo", model: "S60" } ) );
	ormFlush();
	transactionRollback();
}

r1 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id1 } );
r2 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id2 } );

// XC90 was committed (via implicit JDBC commit from setAutoCommit) — should survive
if ( r1.recordCount != 1 )
	throw( message="expected 1 row for XC90 (committed before rollback), got #r1.recordCount#" );

// S60 was saved after the commit point, then rolled back — should be gone
if ( r2.recordCount != 0 )
	throw( message="expected 0 rows for S60 after rollback, got #r2.recordCount#" );

echo( "ok" );
</cfscript>
