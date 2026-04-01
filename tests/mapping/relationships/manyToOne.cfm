<cfscript>
dealer = entityNew( "Dealership", { id: createUUID(), name: "Uptown Auto", address: "123 Auto Way" } );
entitySave( dealer );

auto = entityNew( "Auto", { id: createUUID(), make: "Toyota", model: "Camry", dealer: dealer } );
entitySave( auto );
ormFlush();

// reload and verify relationship
ormClearSession();
loaded = entityLoadByPK( "Auto", auto.getId() );
if ( isNull( loaded.getDealer() ) ) throw( message="many-to-one: dealer should not be null" );
if ( loaded.getDealer().getName() != "Uptown Auto" ) throw( message="many-to-one: expected Uptown Auto, got #loaded.getDealer().getName()#" );

echo( "ok" );
</cfscript>
