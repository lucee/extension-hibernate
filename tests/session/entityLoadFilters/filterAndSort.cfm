<cfscript>
// filter + sort combined
result = entityLoad( "FilterEntity", { status: "active" }, "name ASC" );
if ( arrayLen( result ) != 3 )
	throw( message="filter+sort: expected 3, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "alpha" )
	throw( message="filter+sort: first should be alpha, got #result[ 1 ].getName()#" );
if ( result[ 3 ].getName() != "delta" )
	throw( message="filter+sort: last should be delta, got #result[ 3 ].getName()#" );
echo( "ok" );
</cfscript>
