<cfscript>
// all options combined: filter + sort + maxresults + offset
result = entityLoad( "FilterEntity", { status: "active" }, "name ASC", { maxresults: 2, offset: 0 } );
if ( arrayLen( result ) != 2 )
	throw( message="all options: expected 2, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "alpha" )
	throw( message="all options: first should be alpha, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
