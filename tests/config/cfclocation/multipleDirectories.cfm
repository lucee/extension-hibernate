<cfscript>
// entities from both directories should be discoverable
car = entityNew( "Car", { id: createUUID(), make: "Toyota" } );
entitySave( car );

bike = entityNew( "Bike", { id: createUUID(), brand: "Trek" } );
entitySave( bike );

ormFlush();

// verify both via direct SQL
carResult = queryExecute( "SELECT count(*) as cnt FROM Car" );
if ( carResult.cnt[ 1 ] != 1 )
	throw( message="expected 1 car, got #carResult.cnt[ 1 ]#" );

bikeResult = queryExecute( "SELECT count(*) as cnt FROM Bike" );
if ( bikeResult.cnt[ 1 ] != 1 )
	throw( message="expected 1 bike, got #bikeResult.cnt[ 1 ]#" );

// verify both appear in entityNameArray
names = entityNameArray();
if ( !arrayFindNoCase( names, "Car" ) )
	throw( message="Car not found in entityNameArray: #arrayToList( names )#" );
if ( !arrayFindNoCase( names, "Bike" ) )
	throw( message="Bike not found in entityNameArray: #arrayToList( names )#" );

echo( "ok" );
</cfscript>
