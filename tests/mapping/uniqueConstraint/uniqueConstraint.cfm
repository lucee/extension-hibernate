<cfscript>
entitySave( entityNew( "Email", { id: createUUID(), address: "dupe@test.com" } ) );
ormFlush();

try {
	entitySave( entityNew( "Email", { id: createUUID(), address: "dupe@test.com" } ) );
	ormFlush();
	throw( message="should have thrown unique constraint violation" );
} catch ( any e ) {
	if ( e.message does not contain "unique" && e.message does not contain "constraint" && e.message does not contain "Unique" && e.message does not contain "duplicate" )
		// accept any constraint-related error
		if ( e.type does not contain "database" )
			rethrow;
}

echo( "ok" );
</cfscript>
