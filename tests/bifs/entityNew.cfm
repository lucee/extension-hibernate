<cfscript>
// basic entityNew
auto = entityNew( "Auto" );
if ( !isObject( auto ) ) throw( message="entityNew did not return an object" );

// entityNew with properties
auto2 = entityNew( "Auto", { make: "Ford", model: "Fusion" } );
if ( auto2.getMake() != "Ford" ) throw( message="expected Ford, got #auto2.getMake()#" );
if ( auto2.getModel() != "Fusion" ) throw( message="expected Fusion, got #auto2.getModel()#" );

// entityNew with non-persistent property
auto3 = entityNew( "Auto", { make: "Honda", nonPersistentProp: "abc" } );
if ( auto3.getNonPersistentProp() != "abc" ) throw( message="expected abc, got #auto3.getNonPersistentProp()#" );

// entityNew with undefined property should throw
threw = false;
try {
	entityNew( "Auto", { make: "Ford", propThatDoesntExist: "abc" } );
} catch ( any e ) {
	threw = true;
}
if ( !threw ) throw( message="expected exception for undefined property" );

echo( "ok" );
</cfscript>
