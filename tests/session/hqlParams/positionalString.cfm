<cfscript>
// positional string parameter
result = ormExecuteQuery( "FROM HqlEntity WHERE name = ?1", [ "bravo" ] );
if ( !isArray( result ) || arrayLen( result ) != 1 )
	throw( message="positional string: expected 1 result, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "bravo" )
	throw( message="positional string: expected bravo, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
