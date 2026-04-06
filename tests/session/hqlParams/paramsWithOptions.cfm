<cfscript>
// params + options (maxresults)
result = ormExecuteQuery( "FROM HqlEntity WHERE name = :name", { name: "alpha" }, false, { maxresults: 1 } );
if ( !isArray( result ) || arrayLen( result ) != 1 )
	throw( message="params with options: expected 1 result, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
