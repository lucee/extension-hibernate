<cfscript>
// Regression: ConcurrentModificationException on one-to-many flush
// cborm had to suppress Hibernate log level to work around this.
// See Red Hat KB 29774. Verify our 5.6 logging bridge handles it.
dealerId = createUUID();
dealer = entityNew( "Dealership", { id: dealerId, name: "CME Test Dealer", address: "123 Main St" } );
entitySave( dealer );

// add multiple children
for ( i = 1; i <= 5; i++ ) {
	auto = entityNew( "Auto", { id: createUUID(), make: "Brand #i#", model: "Model #i#", dealer: dealer } );
	entitySave( auto );
}

// this flush is where CME would occur
ormFlush();
ormClearSession();

// verify data persisted
loaded = entityLoadByPK( "Dealership", dealerId );
if ( arrayLen( loaded.getInventory() ) != 5 )
	throw( message="expected 5 autos, got #arrayLen( loaded.getInventory() )#" );

echo( "ok" );
</cfscript>
