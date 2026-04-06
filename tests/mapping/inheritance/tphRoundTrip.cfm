<cfscript>
// Table-per-hierarchy: save Car and Truck, load as Vehicle
carId   = createUUID();
truckId = createUUID();

car = entityNew( "Car", { id: carId, make: "Toyota", model: "Corolla", doors: 4 } );
entitySave( car );

truck = entityNew( "Truck", { id: truckId, make: "Ford", model: "F-150", payload: 1200.5 } );
entitySave( truck );
ormFlush();
ormClearSession();

// polymorphic load — all vehicles
all = entityLoad( "Vehicle" );
if ( !isArray( all ) || arrayLen( all ) != 2 )
	throw( message="expected 2 vehicles, got #isArray( all ) ? arrayLen( all ) : 'non-array'#" );

// verify correct types came back
types = {};
for ( v in all ) {
	types[ v.getMake() ] = getMetadata( v ).name;
}
if ( types[ "Toyota" ] does not contain "Car" )
	throw( message="Toyota should be Car, got #types[ 'Toyota' ]#" );
if ( types[ "Ford" ] does not contain "Truck" )
	throw( message="Ford should be Truck, got #types[ 'Ford' ]#" );

echo( "ok" );
</cfscript>
