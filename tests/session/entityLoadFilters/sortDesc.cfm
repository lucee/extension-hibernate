<cfscript>
// descending sort
result = entityLoad( "FilterEntity", {}, "name DESC" );
if ( result[ 1 ].getName() != "echo" )
	throw( message="sort desc: first should be echo, got #result[ 1 ].getName()#" );
if ( result[ 5 ].getName() != "alpha" )
	throw( message="sort desc: last should be alpha, got #result[ 5 ].getName()#" );
echo( "ok" );
</cfscript>
