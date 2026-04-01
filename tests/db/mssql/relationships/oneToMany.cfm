<cfscript>
dealer = entityNew( "Dealership", { id: createUUID(), name: "Downtown Motors", address: "456 Car St" } );
entitySave( dealer );

auto1 = entityNew( "Auto", { id: createUUID(), make: "Honda", model: "Civic", dealer: dealer } );
auto2 = entityNew( "Auto", { id: createUUID(), make: "Honda", model: "Accord", dealer: dealer } );
entitySave( auto1 );
entitySave( auto2 );
ormFlush();

// reload and verify collection
ormClearSession();
loaded = entityLoadByPK( "Dealership", dealer.getId() );
inv = loaded.getInventory();
if ( isNull( inv ) || !isArray( inv ) ) throw( message="one-to-many: inventory should be an array" );
if ( arrayLen( inv ) != 2 ) throw( message="one-to-many: expected 2 cars, got #arrayLen( inv )#" );

echo( "ok" );
</cfscript>
