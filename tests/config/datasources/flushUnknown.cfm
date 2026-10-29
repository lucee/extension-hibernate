<cfscript>
	// an unknown datasource in the list must throw, and nothing may be flushed before it does
	car = entityNew( "Auto" );
	car.setId( createUUID() );
	car.setMake( "Toyota" );
	car.setModel( "Hilux" );
	entitySave( car );

	thrown = false;
	try {
		ormFlush( "h2,doesNotExist" );
	}
	catch ( any e ) {
		thrown = true;
	}
	if ( !thrown ){
		throw( "ormFlush( ""h2,doesNotExist"" ) did not throw" );
	}

	if ( queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car.getId() }, { datasource: "h2" } ).recordCount ){
		throw( "h2 was flushed although the list contains an unknown datasource" );
	}

	echo( "ok" );
</cfscript>
