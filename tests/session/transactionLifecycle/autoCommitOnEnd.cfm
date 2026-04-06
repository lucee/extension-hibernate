<cfscript>
// Adobe docs: "if cftransaction ends without explicit commit/rollback, it auto-commits"
id = createUUID();

transaction {
	entity = entityNew( "TxEntity", { id: id, name: "AutoCommit" } );
	entitySave( entity );
	// no explicit commit or rollback — should auto-commit
}

// verify it persisted
row = queryExecute( "SELECT count(*) as cnt FROM TX_Entity WHERE id = :id", { id: id } );
if ( row.cnt != 1 )
	throw( message="auto-commit should have persisted entity, got count=#row.cnt#" );

echo( "ok" );
</cfscript>
