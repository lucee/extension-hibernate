<cfscript>
// pagination maxresults
result = entityLoad( "FilterEntity", { status: "active" }, "", { maxresults: 2 } );
if ( arrayLen( result ) != 2 )
	throw( message="maxresults: expected 2, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
