<cfscript>
// LDEV-6203: mixed ORM + queryExecute in a single transaction block.
// Both ORM and regular queries should commit/rollback together.
// This test verifies the basic mixed-mode scenario works correctly.

id = createUUID();

// Test 1: mixed save — both should commit
transaction {
	// ORM save
	auto = entityNew( "Auto", { id: id, make: "Toyota", model: "Supra" } );
	entitySave( auto );

	// regular SQL insert
	queryExecute(
		"INSERT INTO Auto (id, make, model) VALUES (:id, :make, :model)",
		{ id: createUUID(), make: "Nissan", model: "GTR" }
	);
}

result = queryExecute( "SELECT count(*) as cnt FROM Auto" );
if ( result.cnt < 2 )
	throw( message="expected at least 2 rows after mixed commit, got #result.cnt#" );

// clean up for next test
queryExecute( "DELETE FROM Auto" );

// Test 2: mixed rollback — both should revert
id2 = createUUID();
id3 = createUUID();

transaction {
	auto2 = entityNew( "Auto", { id: id2, make: "Honda", model: "NSX" } );
	entitySave( auto2 );

	queryExecute(
		"INSERT INTO Auto (id, make, model) VALUES (:id, :make, :model)",
		{ id: id3, make: "Mazda", model: "RX7" }
	);

	transactionRollback();
}

r1 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id2 } );
r2 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id3 } );
if ( r1.recordCount != 0 )
	throw( message="expected 0 rows for ORM save after mixed rollback, got #r1.recordCount#" );
if ( r2.recordCount != 0 )
	throw( message="expected 0 rows for queryExecute after mixed rollback, got #r2.recordCount#" );

echo( "ok" );
</cfscript>
