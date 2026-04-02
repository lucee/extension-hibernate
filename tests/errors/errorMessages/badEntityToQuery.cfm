<cfscript>
// entityToQuery with a non-entity should throw a helpful error
try {
	entityToQuery( { id: 1, name: "test" } );
	throw( message="should have thrown" );
} catch ( any e ) {
	if ( e.message contains "should have thrown" )
		throw( message="entityToQuery with struct did not throw an error" );

	if ( e.message does not contain "entityToQuery" || e.message does not contain "struct" )
		throw( message="unhelpful error for entityToQuery with non-entity: #e.message#" );
}

echo( "ok" );
</cfscript>
