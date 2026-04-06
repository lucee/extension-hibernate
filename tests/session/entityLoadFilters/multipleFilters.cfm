<cfscript>
// multiple struct filters — multiple Restrictions.eq() calls
result = entityLoad( "FilterEntity", { status: "active", category: "books" } );
if ( arrayLen( result ) != 2 )
	throw( message="multiple filters: expected 2, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
