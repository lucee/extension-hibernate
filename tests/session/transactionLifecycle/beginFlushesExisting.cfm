<cfscript>
// Adobe docs: "Before transaction begins, all existing sessions in the request are flushed."
// Test: save an entity BEFORE the transaction, check if it's visible inside

id = createUUID();
entity = entityNew( "TxEntity", { id: id, name: "BeforeTransaction" } );
entitySave( entity );
// NOT flushing — the entity is dirty in the session

// start transaction
transaction {
	row = queryExecute( "SELECT count(*) as cnt FROM TX_Entity WHERE id = :id", { id: id } );
	if ( row.cnt == 1 ) {
		// ACF behaviour: session was flushed before transaction began
		systemOutput( "NOTE: transaction begin flushed existing session (ACF-compatible)", true );
	} else {
		// Lucee behaviour: session NOT flushed before transaction
		// This is a known difference from ACF — document it
		systemOutput( "NOTE: Lucee does NOT flush existing session when transaction begins (differs from ACF docs)", true );
	}
}

// either way, after transaction ends the entity should be accessible
// flush explicitly to ensure it's persisted
ormFlush();
row2 = queryExecute( "SELECT count(*) as cnt FROM TX_Entity WHERE id = :id", { id: id } );
if ( row2.cnt != 1 )
	throw( message="entity should be in DB after explicit flush, got count=#row2.cnt#" );

echo( "ok" );
</cfscript>
