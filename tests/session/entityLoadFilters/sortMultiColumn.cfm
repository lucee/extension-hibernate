<cfscript>
// multi-column sort
result = entityLoad( "FilterEntity", {}, "status ASC, name ASC" );
if ( arrayLen( result ) != 5 )
	throw( message="multi sort: expected 5, got #arrayLen( result )#" );
// active comes before inactive, within active sorted by name
if ( result[ 1 ].getName() != "alpha" )
	throw( message="multi sort: first should be alpha, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
