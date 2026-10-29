<cfscript>
	// ORMFlush() with a comma separated list with spaces around the names must flush the session of every datasource listed
	car = entityNew( "Auto" );
	car.setId( createUUID() );
	car.setMake( "Toyota" );
	car.setModel( "Hilux" );
	entitySave( car );

	dealer = entityNew( "Dealership" );
	dealer.setId( createUUID() );
	dealer.setName( "Outback Motors" );
	entitySave( dealer );

	// nothing is written before the flush, otherwise this test would prove nothing
	if ( queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car.getId() }, { datasource: "h2" } ).recordCount ){
		throw( "Auto was written to h2 before ORMFlush" );
	}
	if ( queryExecute( "SELECT * FROM Dealership WHERE id=:id", { id: dealer.getId() }, { datasource: "h2_otherDB" } ).recordCount ){
		throw( "Dealership was written to h2_otherDB before ORMFlush" );
	}

	ormFlush( " h2 , h2_otherDB " );

	if ( !queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car.getId() }, { datasource: "h2" } ).recordCount ){
		throw( "Auto not found after ORMFlush — h2 datasource was not flushed" );
	}
	if ( !queryExecute( "SELECT * FROM Dealership WHERE id=:id", { id: dealer.getId() }, { datasource: "h2_otherDB" } ).recordCount ){
		throw( "Dealership not found after ORMFlush — h2_otherDB datasource was not flushed" );
	}

	echo( "ok" );
</cfscript>
