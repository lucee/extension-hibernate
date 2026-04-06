<cfscript>
// cacheable option (requires L2 cache enabled in Application.cfc)
result = entityLoad( "FilterEntity", { status: "active" }, "", { cacheable: true } );
if ( arrayLen( result ) != 3 )
	throw( message="cacheable: expected 3, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
