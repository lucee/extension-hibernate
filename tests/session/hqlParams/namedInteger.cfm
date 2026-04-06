<cfscript>
// named integer parameter
result = ormExecuteQuery( "FROM HqlEntity WHERE id = :id", { id: 1 } );
if ( !isArray( result ) || arrayLen( result ) != 1 )
	throw( message="named integer: expected 1 result, got #arrayLen( result )#" );
if ( result[ 1 ].getId() != 1 )
	throw( message="named integer: expected id 1, got #result[ 1 ].getId()#" );
echo( "ok" );
</cfscript>
