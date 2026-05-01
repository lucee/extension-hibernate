<cfscript>
// LDEV-1697 (related): exercises cfc="dotted.Garage" via a /dotted mapping
// declared in this directory's Application.cfc. The test passes in isolation —
// what fails is the PARENT relationships/Application.cfc whose cfclocation
// recurses into dottedCfcPath/entities/ and pulls Vehicle/Garage into a context
// where /dotted isn't mapped. Disabled at the runner level until Lucee's
// EntityFinder honours nested Application.cfc boundaries.

garage = entityNew( "Garage", { id: createUUID(), name: "Downtown Auto" } );
entitySave( garage );

vehicle = entityNew( "Vehicle", { id: createUUID(), model: "Civic", garage: garage } );
entitySave( vehicle );
ormFlush();

// reload and verify many-to-one resolved through dotted cfc="dotted.Garage"
ormClearSession();
loaded = entityLoadByPK( "Vehicle", vehicle.getId() );
if ( isNull( loaded.getGarage() ) )
	throw( message="dotted cfc path: garage should not be null" );
if ( loaded.getGarage().getName() != "Downtown Auto" )
	throw( message="dotted cfc path: expected Downtown Auto, got #loaded.getGarage().getName()#" );

echo( "ok" );
</cfscript>
