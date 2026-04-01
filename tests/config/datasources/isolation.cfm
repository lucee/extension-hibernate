<cfscript>
// cleanup from prior tests
queryExecute( "DELETE FROM Auto", {}, { datasource: "h2" } );
queryExecute( "DELETE FROM Dealership", {}, { datasource: "h2_otherDB" } );

// verify entities in one datasource are isolated from the other
transaction {
	car = entityNew( "Auto" );
	car.setId( createUUID() );
	car.setMake( "Toyota" );
	car.setModel( "Camry" );
	entitySave( car );

	dealer = entityNew( "Dealership" );
	dealer.setId( createUUID() );
	dealer.setName( "Metro Motors" );
	entitySave( dealer );

	ormFlush();
}

// Auto should be in h2 but NOT in h2_otherDB
autoInMain = queryExecute( "SELECT count(*) as cnt FROM Auto", {}, { datasource: "h2" } );
if ( autoInMain.cnt[ 1 ] != 1 )
	throw( message="expected 1 Auto in h2, got #autoInMain.cnt[ 1 ]#" );

try {
	autoInOther = queryExecute( "SELECT count(*) as cnt FROM Auto", {}, { datasource: "h2_otherDB" } );
	// if Auto table exists in otherDB, it should have 0 rows
	if ( autoInOther.cnt[ 1 ] != 0 )
		throw( message="Auto should not exist in h2_otherDB, got #autoInOther.cnt[ 1 ]# rows" );
} catch ( any e ) {
	// table not found in otherDB is also acceptable — means proper isolation
	if ( e.message contains "should not exist" )
		rethrow;
}

// Dealership should be in h2_otherDB but NOT in h2
dealerInOther = queryExecute( "SELECT count(*) as cnt FROM Dealership", {}, { datasource: "h2_otherDB" } );
if ( dealerInOther.cnt[ 1 ] != 1 )
	throw( message="expected 1 Dealership in h2_otherDB, got #dealerInOther.cnt[ 1 ]#" );

try {
	dealerInMain = queryExecute( "SELECT count(*) as cnt FROM Dealership", {}, { datasource: "h2" } );
	if ( dealerInMain.cnt[ 1 ] != 0 )
		throw( message="Dealership should not exist in h2, got #dealerInMain.cnt[ 1 ]# rows" );
} catch ( any e ) {
	if ( e.message contains "should not exist" )
		rethrow;
}

echo( "ok" );
</cfscript>
