<cfscript>
auto1 = entityNew( "Auto", { id: createUUID(), make: "Toyota", model: "Camry" } );
auto2 = entityNew( "Auto", { id: createUUID(), make: "Ford", model: "Fusion" } );
entitySave( auto1 );
entitySave( auto2 );
ormFlush();

// entityToQuery with array of entities
entities = entityLoad( "Auto" );
qry = entityToQuery( entities );
if ( !isQuery( qry ) ) throw( message="entityToQuery should return query" );
if ( qry.recordCount != 2 ) throw( message="expected 2 rows, got #qry.recordCount#" );

// entityToQuery with single entity
qry2 = entityToQuery( auto1 );
if ( !isQuery( qry2 ) ) throw( message="single entityToQuery should return query" );
if ( qry2.recordCount != 1 ) throw( message="expected 1 row, got #qry2.recordCount#" );

echo( "ok" );
</cfscript>
