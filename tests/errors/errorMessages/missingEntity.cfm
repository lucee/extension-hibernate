<cfscript>
// entityNew with a non-existent entity name should throw a helpful error
try {
	entityNew( "DoesNotExist" );
	throw( message="should have thrown" );
} catch ( any e ) {
	if ( e.message does not contain "No entity" || e.message does not contain "DoesNotExist" )
		throw( message="unhelpful error for missing entity: #e.message#" );
}

echo( "ok" );
</cfscript>
