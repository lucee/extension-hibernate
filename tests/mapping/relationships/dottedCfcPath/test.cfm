<cfscript>
// Adam Tuttle 2019 reported that Lucee rejects fully-qualified CFC paths in
// relationship cfc="..." attributes (e.g. cfc="orm.ems.Person"), requiring bare
// names instead. This test exercises the dotted form via a /dotted mapping
// configured in Application.cfc, asserting the relationship resolves correctly.

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
