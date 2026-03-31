<cfscript>
// preUpdate sets 'updated' to true, persisted to DB
newCar = entityNew( "Auto", { id: createUUID(), make: "Audi" } );
entitySave( newCar );
ormFlush();
if ( newCar.getUpdated() ) throw( message="updated should be false after insert" );

newCar.setModel( "A5" );
entitySave( newCar );
ormFlush();

if ( !newCar.getUpdated() ) throw( message="preUpdate should have set updated=true" );

theID = newCar.getId();
ormClearSession();
persistedCar = entityLoadByPK( "Auto", theID );
if ( !persistedCar.getUpdated() ) throw( message="persisted value should be true" );

echo( "ok" );
</cfscript>
