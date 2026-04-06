<cfscript>
// basic struct filter — hits Restrictions.eq()
result = entityLoad( "FilterEntity", { status: "active" } );
if ( arrayLen( result ) != 3 )
	throw( message="basic filter: expected 3 active, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
