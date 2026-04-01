<cfscript>
// setup
auto = entityNew( "Auto", { make: "Toyota", model: "Camry", id: createUUID() } );
entitySave( auto );
auto2 = entityNew( "Auto", { make: "Ford", model: "Fusion", id: createUUID() } );
entitySave( auto2 );
ormFlush();

// basic HQL
result = ormExecuteQuery( "FROM Auto" );
if ( !isArray( result ) ) throw( message="ormExecuteQuery should return array" );
if ( arrayLen( result ) != 2 ) throw( message="expected 2, got #arrayLen( result )#" );

// HQL with positional params
filtered = ormExecuteQuery( "FROM Auto WHERE make = ?1", [ "Toyota" ] );
if ( arrayLen( filtered ) != 1 ) throw( message="positional: expected 1, got #arrayLen( filtered )#" );

// HQL with named params
named = ormExecuteQuery( "FROM Auto WHERE make = :make", { make: "Ford" } );
if ( arrayLen( named ) != 1 ) throw( message="named: expected 1, got #arrayLen( named )#" );

// unique=true
unique = ormExecuteQuery( "FROM Auto WHERE make = :make", { make: "Toyota" }, true );
if ( !isObject( unique ) ) throw( message="unique should return object" );

echo( "ok" );
</cfscript>
