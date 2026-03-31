<cfscript>
dealer = entityNew( "Dealership", { id: createUUID(), name: "Doomed Dealer", address: "666 Gone St" } );
entitySave( dealer );
auto1 = entityNew( "Auto", { id: createUUID(), make: "Lemon", model: "Bad", dealer: dealer } );
auto2 = entityNew( "Auto", { id: createUUID(), make: "Rust", model: "Bucket", dealer: dealer } );
entitySave( auto1 );
entitySave( auto2 );
ormFlush();

// reload dealer so Hibernate knows about the inventory collection for cascade
ormClearSession();
dealer = entityLoadByPK( "Dealership", dealer.getId() );
// access inventory to hydrate the collection
dealer.getInventory();

// cascade delete-orphan: deleting dealer should delete autos
entityDelete( dealer );
ormFlush();

autos = queryExecute( "SELECT count(*) as cnt FROM Auto WHERE dealerID = :id", { id: dealer.getId() } );
if ( autos.cnt[ 1 ] != 0 ) throw( message="cascade delete: expected 0 autos, got #autos.cnt[ 1 ]#" );

echo( "ok" );
</cfscript>
