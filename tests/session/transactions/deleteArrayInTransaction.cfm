<cfscript>
// Test that EntityDelete with an array of entities works inside a transaction block
// Bug ##4: HibernateORMSession.delete() calls begin() on an already-active transaction
// Only triggers for array deletes, not single entity deletes

id1 = createUUID();
id2 = createUUID();
auto1 = entityNew( "Auto", { id: id1, make: "Toyota", model: "Camry" } );
auto2 = entityNew( "Auto", { id: id2, make: "Ford", model: "Fusion" } );
entitySave( auto1 );
entitySave( auto2 );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE id IN (:id1,:id2)", { id1: id1, id2: id2 } );
if ( result.cnt != 2 ) throw( message="expected 2 rows before delete, got #result.cnt#" );

// array delete inside a transaction — this is the code path that hits the buggy begin()
transaction {
	loaded1 = entityLoadByPK( "Auto", id1 );
	loaded2 = entityLoadByPK( "Auto", id2 );
	entityDelete( [ loaded1, loaded2 ] );
}

result2 = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE id IN (:id1,:id2)", { id1: id1, id2: id2 } );
if ( result2.cnt != 0 ) throw( message="expected 0 rows after array delete in transaction, got #result2.cnt#" );

echo( "ok" );
</cfscript>
