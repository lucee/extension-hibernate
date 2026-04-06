<cfscript>
// sort only — hits Order.asc()
result = entityLoad( "FilterEntity", {}, "name ASC" );
if ( arrayLen( result ) != 5 )
	throw( message="sort asc: expected 5, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "alpha" )
	throw( message="sort asc: first should be alpha, got #result[ 1 ].getName()#" );
if ( result[ 5 ].getName() != "echo" )
	throw( message="sort asc: last should be echo, got #result[ 5 ].getName()#" );
echo( "ok" );
</cfscript>
