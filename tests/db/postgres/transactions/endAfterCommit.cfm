<cfscript>
// Test that a transaction block commits and persists correctly
// Bug #3: HibernateORMTransaction.end() checks COMMITTED instead of ACTIVE
// The transaction block's implicit end() should commit if active, not if already committed

id = createUUID();
transaction {
	auto = entityNew( "Auto", { id: id, make: "Honda", model: "Civic" } );
	entitySave( auto );
}
// transaction block calls end() implicitly — should flush + commit

result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 ) throw( message="expected 1 row after transaction end, got #result.recordCount#" );
if ( result.make != "Honda" ) throw( message="expected Honda, got #result.make#" );

echo( "ok" );
</cfscript>
