<cfscript>
id = createUUID();
auto = entityNew( "Auto", { make: "Toyota", model: "Camry", id: id } );
entitySave( auto );
ormFlush();

loaded = entityLoadByPK( "Auto", id );
if ( !isObject( loaded ) ) throw( message="entityLoadByPK should return object" );
if ( loaded.getMake() != "Toyota" ) throw( message="expected Toyota, got #loaded.getMake()#" );

// non-existent PK returns null
missing = entityLoadByPK( "Auto", "doesnotexist" );
if ( !isNull( missing ) ) throw( message="expected null for missing PK" );

echo( "ok" );
</cfscript>
