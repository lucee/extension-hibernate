<cfscript>
id = createUUID();
auto = entityNew( "Auto", { make: "Toyota", model: "Camry", id: id } );
entitySave( auto );
ormFlush();

// modify in memory
auto.setModel( "Rav4" );
// reload from DB — should revert
entityReload( auto );
if ( auto.getModel() != "Camry" ) throw( message="expected Camry after reload, got #auto.getModel()#" );

echo( "ok" );
</cfscript>
