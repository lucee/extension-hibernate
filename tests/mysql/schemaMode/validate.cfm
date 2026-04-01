<cfscript>
// dbcreate=validate: ORM should throw when schema doesn't match
// with a fresh H2 database, there's no Item table — validation should fail
try {
	item = entityNew( "Item", { id: createUUID(), name: "test" } );
	entitySave( item );
	ormFlush();
	throw( message="should have thrown — validate mode with missing table" );
} catch ( any e ) {
	if ( e.message contains "should have thrown" )
		throw( message="validate did not throw on missing schema" );
	// any other error means validate correctly detected schema mismatch
}

echo( "ok" );
</cfscript>
