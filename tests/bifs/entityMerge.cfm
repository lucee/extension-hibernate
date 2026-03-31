<cfscript>
auto = entityNew( "Auto", { make: "Toyota", id: createUUID() } );
entitySave( auto );
ormFlush();

merged = entityMerge( auto );
if ( !isObject( merged ) ) throw( message="entityMerge should return object" );
if ( merged.getMake() != "Toyota" ) throw( message="expected Toyota, got #merged.getMake()#" );

echo( "ok" );
</cfscript>
