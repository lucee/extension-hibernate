<cfscript>
// OOE-16 / LDEV-87: persistent="false" override on MappedSuperClass property
// The child entity overrides legacyCode with persistent="false",
// so the column should NOT exist in the table and should not be mapped.

child = entityNew( "ChildEntity", { id: createUUID(), name: "test" } );
entitySave( child );
ormFlush();

// Verify we can load it back
loaded = entityLoadByPK( "ChildEntity", child.getId() );
if ( loaded.getName() != "test" )
	throw( message="expected name=test, got #loaded.getName()#" );

// Verify the legacyCode column does NOT exist in the table
try {
	queryExecute( "SELECT legacyCode FROM OOE16_Child" );
	throw( message="legacyCode column should NOT exist — persistent='false' was ignored" );
} catch ( any e ) {
	if ( e.message contains "should NOT exist" )
		rethrow;
	// Expected: column not found error means persistent="false" worked
}

echo( "ok" );
</cfscript>
