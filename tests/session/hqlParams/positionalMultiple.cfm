<cfscript>
// multiple positional parameters
result = ormExecuteQuery( "FROM HqlEntity WHERE id = ?1 AND name = ?2", [ 1, "alpha" ] );
if ( !isArray( result ) || arrayLen( result ) != 1 )
	throw( message="positional multiple: expected 1 result, got #arrayLen( result )#" );
if ( result[ 1 ].getId() != 1 )
	throw( message="positional multiple: expected id 1, got #result[ 1 ].getId()#" );
echo( "ok" );
</cfscript>
