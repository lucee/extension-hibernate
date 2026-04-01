<cfscript>
// preInsert sets 'inserted' to true, persisted to DB
newCar = entityNew( "Auto", { id: createUUID(), make: "BMW" } );
if ( newCar.getInserted() ) throw( message="inserted should be false before flush" );

entitySave( newCar );
ormFlush();

if ( !newCar.getInserted() ) throw( message="preInsert should have set inserted=true" );

// verify it persisted
theID = newCar.getId();
ormClearSession();
persistedCar = entityLoadByPK( "Auto", theID );
if ( !persistedCar.getInserted() ) throw( message="persisted value should be true" );

echo( "ok" );
</cfscript>
