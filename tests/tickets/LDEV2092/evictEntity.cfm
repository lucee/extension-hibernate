<cfscript>
// LDEV-2092: ormEvictEntity throws "Unknown entity" with multiple datasources + L2 cache
// Auto is on "h2", Dealership is on "h2_otherDB"

// save one of each
car = entityNew( "Auto", { id: createUUID(), make: "Toyota", model: "Supra" } );
entitySave( car );
dealer = entityNew( "Dealership", { id: createUUID(), name: "Test Dealer" } );
entitySave( dealer );
ormFlush();

// evict entity on default datasource — should not throw
ormEvictEntity( "Auto" );

// evict entity on non-default datasource — this is the LDEV-2092 bug
ormEvictEntity( "Dealership" );

// evict with specific PK
ormEvictEntity( "Auto", car.getId() );
ormEvictEntity( "Dealership", dealer.getId() );

echo( "ok" );
</cfscript>
