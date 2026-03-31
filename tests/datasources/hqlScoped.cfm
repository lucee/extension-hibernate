<cfscript>
// cleanup from prior tests
queryExecute( "DELETE FROM Auto", {}, { datasource: "h2" } );
queryExecute( "DELETE FROM Dealership", {}, { datasource: "h2_otherDB" } );

// verify HQL and entityLoad work for entities on different datasources
transaction {
	car = entityNew( "Auto", { id: createUUID(), make: "Honda", model: "Civic" } );
	entitySave( car );

	dealer = entityNew( "Dealership", { id: createUUID(), name: "Southside Autos" } );
	entitySave( dealer );

	ormFlush();
}

// HQL query for Auto (default datasource h2)
autos = ormExecuteQuery( "FROM Auto WHERE make = :make", { make: "Honda" } );
if ( arrayLen( autos ) != 1 )
	throw( message="HQL: expected 1 Auto, got #arrayLen( autos )#" );
if ( autos[ 1 ].getModel() != "Civic" )
	throw( message="HQL: expected Civic, got #autos[ 1 ].getModel()#" );

// entityLoad for Dealership (h2_otherDB datasource — HQL won't work cross-datasource)
dealers = entityLoad( "Dealership", { name: "Southside Autos" } );
if ( arrayLen( dealers ) != 1 )
	throw( message="entityLoad: expected 1 Dealership, got #arrayLen( dealers )#" );

echo( "ok" );
</cfscript>
