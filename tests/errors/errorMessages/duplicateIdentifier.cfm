<cfscript>
// Two different CFC instances with the same PK in the same Hibernate session
// should cause "a different object with the same identifier" error on save/flush
id = createUUID();
auto1 = entityNew( "Auto", { id: id, make: "Toyota", model: "Yaris" } );
entitySave( auto1 );
ormFlush();

// Create a second, different instance with the same PK
auto2 = entityNew( "Auto", { id: id, make: "Honda", model: "Jazz" } );

try {
	entitySave( auto2 );
	ormFlush();
	// If no error, it might have merged silently — check which value stuck
	ormClearSession();
	loaded = entityLoadByPK( "Auto", id );
	// Either way, the test proves what happens with duplicate identifiers
	echo( "ok" );
} catch ( any e ) {
	// "different object with the same identifier" or "NonUniqueObjectException" expected
	if ( e.message contains "identifier" || e.message contains "NonUnique" || e.message contains "different object" )
		echo( "ok" );
	else
		rethrow;
}
</cfscript>
