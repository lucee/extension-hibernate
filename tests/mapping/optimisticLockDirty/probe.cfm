<cfscript>
// Probe: SF builds with optimistic-lock="dirty" and a basic save+update+reload works.
try {
	transaction {
		e = entityNew( "DirtyEntity" );
		e.setName( "alpha" );
		e.setAge( 30 );
		entitySave( e );
	}
	ormFlush();
	ormClearSession();

	transaction {
		loaded = entityLoad( "DirtyEntity", e.getId(), true );
		loaded.setAge( 31 );
	}
	ormFlush();
	ormClearSession();

	finalRow = entityLoad( "DirtyEntity", e.getId(), true );
	if ( finalRow.getAge() != 31 )
		throw( message="expected age 31 after update, got [#finalRow.getAge()#]" );
	if ( finalRow.getName() != "alpha" )
		throw( message="expected name [alpha] preserved, got [#finalRow.getName()#]" );
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
