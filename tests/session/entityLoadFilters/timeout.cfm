<cfscript>
// timeout option
result = entityLoad( "FilterEntity", { status: "active" }, "", { timeout: 30 } );
if ( arrayLen( result ) != 3 )
	throw( message="timeout: expected 3, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
