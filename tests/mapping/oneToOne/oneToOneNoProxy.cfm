<cfscript>
// lazy="no-proxy" on one-to-one — bytecode instrumentation instead of proxy
cid = createUUID();
citizen = entityNew( "Citizen", { id: cid, name: "Charlie" } );
entitySave( citizen );

passport = entityNew( "NoProxyPassport", { id: cid, number: "NZ111222" } );
entitySave( passport );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "NoProxyPassport", cid );
holder = loaded.getHolder();
if ( !isObject( holder ) )
	throw( message="no-proxy holder should load on access" );
if ( holder.getName() != "Charlie" )
	throw( message="expected Charlie, got #holder.getName()#" );

echo( "ok" );
</cfscript>
