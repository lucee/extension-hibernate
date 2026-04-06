<cfscript>
// unique=true with no filter — multiple rows exist, should throw
try {
	result = entityLoad( "FilterEntity", {}, true );
	throw( message="unique no filter: should have thrown with multiple rows" );
} catch ( any e ) {
	if ( e.message contains "unique no filter" ) rethrow;
	// expected — non-unique result throws
}
echo( "ok" );
</cfscript>
