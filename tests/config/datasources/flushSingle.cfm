<cfscript>
	// ORMFlush() with one datasource name flushes only that datasource, ORMFlush() without argument only the default one
	car = entityNew( "Auto" );
	car.setId( createUUID() );
	car.setMake( "Toyota" );
	car.setModel( "Hilux" );
	entitySave( car );

	dealer = entityNew( "Dealership" );
	dealer.setId( createUUID() );
	dealer.setName( "Outback Motors" );
	entitySave( dealer );

	function inAuto() {
		return queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car.getId() }, { datasource: "h2" } ).recordCount;
	}
	function inDealership() {
		return queryExecute( "SELECT * FROM Dealership WHERE id=:id", { id: dealer.getId() }, { datasource: "h2_otherDB" } ).recordCount;
	}

	if ( inAuto() || inDealership() ){
		throw( "entities were written before ORMFlush" );
	}

	// single name, other datasource stays unflushed
	ormFlush( "h2_otherDB" );
	if ( !inDealership() ){
		throw( "Dealership not found after ormFlush( ""h2_otherDB"" )" );
	}
	if ( inAuto() ){
		throw( "Auto was written to h2 by ormFlush( ""h2_otherDB"" )" );
	}

	// no argument, default datasource
	ormFlush();
	if ( !inAuto() ){
		throw( "Auto not found after ormFlush() — default datasource was not flushed" );
	}

	// single name for the default datasource
	car2 = entityNew( "Auto" );
	car2.setId( createUUID() );
	car2.setMake( "Honda" );
	car2.setModel( "Civic" );
	entitySave( car2 );
	ormFlush( "h2" );
	if ( !queryExecute( "SELECT * FROM Auto WHERE id=:id", { id: car2.getId() }, { datasource: "h2" } ).recordCount ){
		throw( "Auto not found after ormFlush( ""h2"" )" );
	}

	echo( "ok" );
</cfscript>
