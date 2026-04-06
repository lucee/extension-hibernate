<cfscript>
// Adobe docs: "the session participating in the transaction is cleared when transaction is rolled back"
// After rollback, entities in session should be stale/detached

id = createUUID();

transaction {
	entity = entityNew( "TxEntity", { id: id, name: "WillRollback" } );
	entitySave( entity );
	ormFlush();

	// verify it's in DB within transaction
	row = queryExecute( "SELECT count(*) as cnt FROM TX_Entity WHERE id = :id", { id: id } );
	if ( row.cnt != 1 )
		throw( message="entity should be in DB within transaction, got count=#row.cnt#" );

	transactionRollback();
}

// after rollback, the entity should NOT be in DB
row2 = queryExecute( "SELECT count(*) as cnt FROM TX_Entity WHERE id = :id", { id: id } );
if ( row2.cnt != 0 )
	throw( message="after rollback, entity should NOT be in DB, got count=#row2.cnt#" );

echo( "ok" );
</cfscript>
