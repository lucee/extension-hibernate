<cfscript>
// named date parameter — most likely to break with java.time changes
targetDate = createDate( 2025, 6, 15 );
result = ormExecuteQuery( "FROM HqlEntity WHERE created = :dt", { dt: targetDate } );
if ( !isArray( result ) || arrayLen( result ) != 1 )
	throw( message="named date: expected 1 result, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "alpha" )
	throw( message="named date: expected alpha, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
