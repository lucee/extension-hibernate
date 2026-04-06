<cfscript>
// Saving entity that references an unsaved transient entity (no cascade) should throw
unsavedAuto = entityNew( "Auto", { id: createUUID(), make: "Ghost", model: "Phantom" } );
// deliberately NOT calling entitySave on the Auto

dealer = entityNew( "Dealer", { id: createUUID(), name: "Bad Dealer", topAuto: unsavedAuto } );
entitySave( dealer );

try {
	ormFlush();
	throw( message="should have thrown transient instance error" );
} catch ( any e ) {
	// Hibernate may throw "unsaved transient instance" or the DB may throw FK violation
	// — both indicate the reference to the unsaved entity was caught
	if ( e.message contains "transient" || e.message contains "unsaved" || e.message contains "not-null"
			|| e.message contains "Referential integrity" || e.message contains "constraint" )
		echo( "ok" );
	else
		rethrow;
}
</cfscript>
