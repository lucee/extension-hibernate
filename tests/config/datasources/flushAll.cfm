<cfscript>
	car = entityNew( "Auto" );
	car.setId( createUUID() );
	car.setMake( "Toyota" );
	car.setModel( "Hilux" );
	entitySave( car );

	dealer = entityNew( "Dealership" );
	dealer.setId( createUUID() );
	dealer.setName( "Outback Motors" );
	entitySave( dealer );

	// flush both datasources in one call
	ORMFlushAll();

	autoResults = queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car.getId() }, { datasource: "h2" } );
	if ( !autoResults.recordCount ){
		throw( "Auto not found after ORMFlushAll — h2 datasource was not flushed" );
	}

	dealerResults = queryExecute( "SELECT * FROM Dealership WHERE id=:id", { id: dealer.getId() }, { datasource: "h2_otherDB" } );
	if ( !dealerResults.recordCount ){
		throw( "Dealership not found after ORMFlushAll — h2_otherDB datasource was not flushed" );
	}

	echo( "ok" );
</cfscript>
