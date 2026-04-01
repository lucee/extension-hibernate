<cfscript>
id = createUUID();
transaction {
	auto = entityNew( "Auto", { id: id, make: "Ford", model: "Fusion" } );
	entitySave( auto );
	// no explicit commit — transaction block end should commit
}
result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 ) throw( message="expected 1 row after implicit commit, got #result.recordCount#" );

echo( "ok" );
</cfscript>
