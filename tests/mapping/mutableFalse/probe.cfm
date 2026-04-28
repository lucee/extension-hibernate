<cfscript>
// Probe: SF builds with mutable="false" + initial insert works + post-insert load round-trips.
try {
	transaction {
		e = entityNew( "Frozen" );
		e.setName( "alpha" );
		entitySave( e );
	}
	ormFlush();
	ormClearSession();

	loaded = entityLoad( "Frozen", e.getId(), true );
	if ( loaded.getName() != "alpha" )
		throw( message="expected name [alpha], got [#loaded.getName()#]" );
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
