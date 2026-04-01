<cfscript>
dealer = entityNew( "Dealership", { id: createUUID(), name: "Test Dealer", address: "789 Evict Ln" } );
entitySave( dealer );
auto = entityNew( "Auto", { id: createUUID(), make: "Ford", model: "Focus", dealer: dealer } );
entitySave( auto );
ormFlush();

// evict the collection from second-level cache — should not throw
ormEvictCollection( "Dealership", "inventory" );

// evict by specific ID
ormEvictCollection( "Dealership", "inventory", dealer.getId() );

echo( "ok" );
</cfscript>
