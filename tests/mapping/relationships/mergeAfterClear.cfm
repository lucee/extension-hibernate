<cfscript>
// LDEV-1992: entityMerge after ormClearSession should not throw
// "could not initialize proxy - no Session" on lazy relationships

dealer = entityNew( "Dealership", { id: createUUID(), name: "Merge Motors", address: "1 Merge St" } );
entitySave( dealer );
auto = entityNew( "Auto", { id: createUUID(), make: "Honda", model: "Civic", dealer: dealer } );
entitySave( auto );
ormFlush();
ormClearSession();

// Load auto — dealer property is a lazy proxy
loaded = entityLoadByPK( "Auto", auto.getId() );
if ( isNull( loaded ) ) throw( message="auto not loaded" );

// Clear session — detaches everything, proxy session reference goes stale
ormClearSession();

// Merge the detached entity back — this is the LDEV-1992 failure point
merged = entityMerge( loaded );
if ( isNull( merged ) ) throw( message="entityMerge returned null" );
if ( merged.getMake() != "Honda" ) throw( message="expected Honda, got #merged.getMake()#" );

// The merged entity's lazy dealer should be accessible
mergedDealer = merged.getDealer();
if ( isNull( mergedDealer ) ) throw( message="merged dealer is null" );
if ( mergedDealer.getName() != "Merge Motors" ) throw( message="expected Merge Motors, got #mergedDealer.getName()#" );

echo( "ok" );
</cfscript>
