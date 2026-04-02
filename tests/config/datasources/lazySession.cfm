<cfscript>
	// Test that sessions are opened lazily per datasource.
	// Only the datasource you actually use should get a session opened.

	// Step 1: use ONLY the default datasource (h2) — h2_otherDB should not be touched
	car = entityNew( "Auto" );
	car.setId( createUUID() );
	car.setMake( "Toyota" );
	car.setModel( "Supra" );
	entitySave( car );
	ormFlush();

	// verify it persisted
	autoResults = queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car.getId() }, { datasource: "h2" } );
	if ( !autoResults.recordCount )
		throw( "Auto not saved to default datasource" );

	// Step 2: NOW use the second datasource — session should be created on demand
	dealer = entityNew( "Dealership" );
	dealer.setId( createUUID() );
	dealer.setName( "Lazy Motors" );
	entitySave( dealer );
	ormFlush( "h2_otherDB" );

	dealerResults = queryExecute( "SELECT * FROM Dealership WHERE id=:id", { id: dealer.getId() }, { datasource: "h2_otherDB" } );
	if ( !dealerResults.recordCount )
		throw( "Dealership not saved to second datasource" );

	// Step 3: verify both datasources still work after lazy init
	car2 = entityNew( "Auto" );
	car2.setId( createUUID() );
	car2.setMake( "Honda" );
	car2.setModel( "Civic" );
	entitySave( car2 );

	dealer2 = entityNew( "Dealership" );
	dealer2.setId( createUUID() );
	dealer2.setName( "Late Openers" );
	entitySave( dealer2 );

	ormFlush();
	ormFlush( "h2_otherDB" );

	autoResults2 = queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car2.getId() }, { datasource: "h2" } );
	dealerResults2 = queryExecute( "SELECT * FROM Dealership WHERE id=:id", { id: dealer2.getId() }, { datasource: "h2_otherDB" } );

	if ( !autoResults2.recordCount )
		throw( "Second Auto not saved after both datasources active" );
	if ( !dealerResults2.recordCount )
		throw( "Second Dealership not saved after both datasources active" );

	echo( "ok" );
</cfscript>
