<cfscript>
entitySave( entityNew( "Auto", { id: createUUID(), make: "Toyota", model: "Camry" } ) );
entitySave( entityNew( "Auto", { id: createUUID(), make: "Toyota", model: "Rav4" } ) );
entitySave( entityNew( "Auto", { id: createUUID(), make: "Ford", model: "Fusion" } ) );
ormFlush();

// loadByExample with a sample entity
sample = entityNew( "Auto" );
sample.setMake( "Toyota" );
result = entityLoadByExample( sample );
if ( !isArray( result ) ) throw( message="entityLoadByExample should return array" );
if ( arrayLen( result ) != 2 ) throw( message="expected 2 Toyotas, got #arrayLen( result )#" );

// unique=true
sample2 = entityNew( "Auto" );
sample2.setMake( "Ford" );
unique = entityLoadByExample( sample2, true );
if ( !isObject( unique ) ) throw( message="unique entityLoadByExample should return object" );
if ( unique.getModel() != "Fusion" ) throw( message="expected Fusion, got #unique.getModel()#" );

echo( "ok" );
</cfscript>
