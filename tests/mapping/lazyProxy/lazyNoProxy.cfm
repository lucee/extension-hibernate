<cfscript>
// lazy="no-proxy" uses bytecode instrumentation instead of proxy objects
// Verify the mapping is accepted and data loads correctly
addrId = createUUID();
custId = createUUID();

addr = entityNew( "Address", { id: addrId, city: "Sydney" } );
entitySave( addr );
cust = entityNew( "NoProxyCustomer", { id: custId, name: "Test", address: addr } );
entitySave( cust );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "NoProxyCustomer", custId );
if ( loaded.getAddress().getCity() != "Sydney" )
	throw( message="expected Sydney, got #loaded.getAddress().getCity()#" );

echo( "ok" );
</cfscript>
