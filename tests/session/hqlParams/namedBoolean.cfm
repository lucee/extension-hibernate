<cfscript>
// named boolean parameter
result = ormExecuteQuery( "FROM HqlEntity WHERE active = :active", { active: true } );
if ( !isArray( result ) || arrayLen( result ) != 3 )
	throw( message="named boolean: expected 3 active results, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
