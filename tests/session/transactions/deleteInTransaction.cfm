<cfscript>
// Test that EntityDelete works within a transaction block
// Bug #4: HibernateORMSession.delete() calls begin() when transaction is already active

id = createUUID();
auto = entityNew( "Auto", { id: id, make: "Toyota", model: "Camry" } );
entitySave( auto );
ormFlush();

// verify it's there
result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 ) throw( message="expected 1 row before delete, got #result.recordCount#" );

// delete inside a transaction block — this triggers the buggy code path
// where delete() calls trans.begin() on an already-active transaction
transaction {
	loaded = entityLoadByPK( "Auto", id );
	entityDelete( loaded );
}

result2 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result2.recordCount != 0 ) throw( message="expected 0 rows after delete in transaction, got #result2.recordCount#" );

echo( "ok" );
</cfscript>
