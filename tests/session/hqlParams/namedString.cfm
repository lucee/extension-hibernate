<cfscript>
// named string parameter — exercises Restrictions.eq() via HQL
result = ormExecuteQuery( "FROM HqlEntity WHERE name = :name", { name: "alpha" } );
if ( !isArray( result ) || arrayLen( result ) != 2 )
	throw( message="named string: expected 2 results, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "alpha" )
	throw( message="named string: expected alpha, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
