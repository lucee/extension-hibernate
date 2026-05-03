<cfscript>
// Verifies property cfc="dotted.Garage" resolves through the /dotted mapping
// declared in this directory's Application.cfc.

garage = entityNew( "Garage", { id: createUUID(), name: "Downtown Auto" } );
entitySave( garage );

vehicle = entityNew( "Vehicle", { id: createUUID(), model: "Civic", garage: garage } );
entitySave( vehicle );
ormFlush();

ormClearSession();
loaded = entityLoadByPK( "Vehicle", vehicle.getId() );
if ( isNull( loaded.getGarage() ) )
	throw( message="dotted cfc path: garage should not be null" );
if ( loaded.getGarage().getName() != "Downtown Auto" )
	throw( message="dotted cfc path: expected Downtown Auto, got #loaded.getGarage().getName()#" );

echo( "ok" );
</cfscript>
