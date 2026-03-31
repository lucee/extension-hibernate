<cfscript>
// setup
auto = entityNew( "Auto", { make: "Toyota", model: "Camry", id: createUUID() } );
entitySave( auto );
auto2 = entityNew( "Auto", { make: "Ford", model: "Fusion", id: createUUID() } );
entitySave( auto2 );
ormFlush();

// entityLoad returns array
result = entityLoad( "Auto" );
if ( !isArray( result ) ) throw( message="entityLoad should return array" );
if ( arrayLen( result ) != 2 ) throw( message="expected 2, got #arrayLen( result )#" );

// entityLoad with filter struct
filtered = entityLoad( "Auto", { make: "Toyota" } );
if ( arrayLen( filtered ) != 1 ) throw( message="filtered: expected 1, got #arrayLen( filtered )#" );

// entityLoad with unique=true
unique = entityLoad( "Auto", { make: "Ford" }, true );
if ( !isObject( unique ) ) throw( message="unique load should return object" );
if ( unique.getModel() != "Fusion" ) throw( message="expected Fusion, got #unique.getModel()#" );

// entityLoad by id
byId = entityLoad( "Auto", auto.getId(), true );
if ( byId.getMake() != "Toyota" ) throw( message="byId: expected Toyota, got #byId.getMake()#" );

echo( "ok" );
</cfscript>
