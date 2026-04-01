<cfscript>
dealer = entityNew( "Dealership", { id: createUUID(), name: "Lazy Motors", address: "1 Lazy Ln" } );
entitySave( dealer );
auto = entityNew( "Auto", { id: createUUID(), make: "Tesla", model: "3", dealer: dealer } );
entitySave( auto );
ormFlush();
ormClearSession();

// Load the auto — dealer should be lazy-loaded
loaded = entityLoadByPK( "Auto", auto.getId() );
if ( isNull( loaded ) ) throw( message="auto not loaded" );

// Accessing the dealer should trigger lazy load
dealerName = loaded.getDealer().getName();
if ( dealerName != "Lazy Motors" ) throw( message="lazy load: expected Lazy Motors, got #dealerName#" );

// Load dealer — inventory should be lazy-loaded
ormClearSession();
loadedDealer = entityLoadByPK( "Dealership", dealer.getId() );
inv = loadedDealer.getInventory();
if ( !isArray( inv ) ) throw( message="inventory should be array" );
if ( arrayLen( inv ) != 1 ) throw( message="lazy load collection: expected 1, got #arrayLen( inv )#" );
if ( inv[ 1 ].getMake() != "Tesla" ) throw( message="lazy load collection: expected Tesla, got #inv[ 1 ].getMake()#" );

echo( "ok" );
</cfscript>
