<cfscript>
// HQL query against base entity returns mixed subclass types
carId   = createUUID();
truckId = createUUID();

entitySave( entityNew( "Car", { id: carId, make: "Subaru", model: "WRX", doors: 4 } ) );
entitySave( entityNew( "Truck", { id: truckId, make: "Subaru", model: "Brat", payload: 900.0 } ) );
ormFlush();
ormClearSession();

results = ORMExecuteQuery( "from Vehicle where make = :make", { make: "Subaru" } );
if ( arrayLen( results ) != 2 )
	throw( message="expected 2 Subaru vehicles, got #arrayLen( results )#" );

echo( "ok" );
</cfscript>
