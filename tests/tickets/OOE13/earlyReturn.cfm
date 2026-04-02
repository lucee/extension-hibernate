<cfscript>
// OOE-13: transaction block with early return should still commit/close.
// Bug: Lucee core calls commit() in afterBody, not doFinally, so return skips it.

function saveWithReturn() {
	var id = createUUID();
	transaction {
		var auto = entityNew( "Auto", { id: id, make: "BMW" } );
		entitySave( auto );
		return id;
	}
}

id1 = saveWithReturn();

// First save should have committed
result1 = queryExecute( "SELECT * FROM OOE13_Auto WHERE id = :id", { id: id1 } );
if ( result1.recordCount != 1 )
	throw( message="first transaction: expected 1 row, got #result1.recordCount#" );

// Second transaction should NOT hang/timeout (proves first one released locks)
id2 = createUUID();
transaction {
	auto2 = entityNew( "Auto", { id: id2, make: "Audi" } );
	entitySave( auto2 );
}

result2 = queryExecute( "SELECT * FROM OOE13_Auto WHERE id = :id", { id: id2 } );
if ( result2.recordCount != 1 )
	throw( message="second transaction: expected 1 row, got #result2.recordCount#" );

echo( "ok" );
</cfscript>
