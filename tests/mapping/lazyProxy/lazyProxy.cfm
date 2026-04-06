<cfscript>
addrId = createUUID();
custId = createUUID();

addr = entityNew( "Address", { id: addrId, city: "Melbourne" } );
entitySave( addr );
cust = entityNew( "Customer", { id: custId, name: "Zac", address: addr } );
entitySave( cust );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Customer", custId );
// accessing the proxy should trigger load
city = loaded.getAddress().getCity();
if ( city != "Melbourne" )
	throw( message="expected Melbourne, got #city#" );

echo( "ok" );
</cfscript>
