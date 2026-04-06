<cfscript>
// numeric collection parameter via setParameterList()
result = ormExecuteQuery( "FROM HqlEntity WHERE id IN (:ids)", { ids: [ 1, 2, 3 ] } );
if ( !isArray( result ) || arrayLen( result ) != 3 )
	throw( message="collection numeric: expected 3 results, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
