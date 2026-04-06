<cfscript>
// collection parameter via setParameterList() — string list
result = ormExecuteQuery( "FROM HqlEntity WHERE name IN (:names)", { names: [ "alpha", "bravo", "charlie" ] } );
if ( !isArray( result ) || arrayLen( result ) != 4 )
	throw( message="collection string: expected 4 results, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
