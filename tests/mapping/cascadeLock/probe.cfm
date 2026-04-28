<cfscript>
// Probe: SF builds with cascade="lock" + basic round-trip works.
try {
	transaction {
		parent = entityNew( "LockParent" );
		parent.setName( "LockRoot" );
		entitySave( parent );

		child = entityNew( "LockChild" );
		child.setName( "LockKid" );
		child.setParent( parent );
		entitySave( child );
	}
	ormFlush();
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
