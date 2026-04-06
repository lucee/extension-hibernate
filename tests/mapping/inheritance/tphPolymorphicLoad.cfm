<cfscript>
// Load subclass via base entity name — should return the correct subclass type
carId = createUUID();
car = entityNew( "Car", { id: carId, make: "Honda", model: "Civic", doors: 4 } );
entitySave( car );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Vehicle", carId );
if ( !isObject( loaded ) )
	throw( message="should load vehicle by PK" );

// should actually be a Car instance with doors accessible
if ( getMetadata( loaded ).name does not contain "Car" )
	throw( message="expected Car type, got #getMetadata( loaded ).name#" );
if ( loaded.getDoors() != 4 )
	throw( message="expected 4 doors, got #loaded.getDoors()#" );

echo( "ok" );
</cfscript>
