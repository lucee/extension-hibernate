<cfscript>
// unique=true with named param
result = ormExecuteQuery( "FROM HqlEntity WHERE name = :name", { name: "bravo" }, true );
if ( isNull( result ) )
	throw( message="unique with param: expected entity, got null" );
if ( !isObject( result ) )
	throw( message="unique with param: expected object, got #getMetadata( result ).getName()#" );
if ( result.getName() != "bravo" )
	throw( message="unique with param: expected bravo, got #result.getName()#" );
echo( "ok" );
</cfscript>
