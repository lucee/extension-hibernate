<cfscript>
// save new entity
auto = entityNew( "Auto", { make: "Toyota", id: createUUID() } );
entitySave( auto );
ormFlush();
result = queryExecute( "SELECT id FROM Auto" );
if ( result.recordCount != 1 ) throw( message="expected 1 row, got #result.recordCount#" );

// save existing entity (update)
auto.setModel( "Rav4" );
entitySave( auto );
ormFlush();
updated = queryExecute( "SELECT model FROM Auto" );
if ( updated.model[ 1 ] != "Rav4" ) throw( message="expected Rav4, got #updated.model[ 1 ]#" );

// forceInsert=false
auto2 = entityNew( "Auto", { make: "Ford", model: "Fusion", id: createUUID() } );
entitySave( auto2, false );
ormFlush();
result2 = queryExecute( "SELECT id FROM Auto" );
if ( result2.recordCount != 2 ) throw( message="expected 2 rows, got #result2.recordCount#" );

echo( "ok" );
</cfscript>
