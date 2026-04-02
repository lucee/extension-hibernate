<cfscript>
// LDEV-2092: ormEvictCollection on non-default datasource
// Dealership + Vehicle are both on "h2_otherDB"

dealer = entityNew( "Dealership", { id: createUUID(), name: "Test Dealer" } );
entitySave( dealer );
vehicle = entityNew( "Vehicle", { id: createUUID(), vin: "ABC123", dealer: dealer } );
entitySave( vehicle );
ormFlush();

// evict the collection from L2 cache — should not throw
ormEvictCollection( "Dealership", "inventory" );

// evict by specific ID
ormEvictCollection( "Dealership", "inventory", dealer.getId() );

echo( "ok" );
</cfscript>
