<cfscript>
// SF must build with the multi-token cascade and entity round-trip cleanly.
try {
	parent = entityNew( "ValidParent" );
	parent.setName( "Root" );

	child = entityNew( "ValidChild" );
	child.setName( "Kid" );
	child.setParent( parent );

	parent.setChildren( [ child ] );

	transaction {
		entitySave( parent );
		entitySave( child );
	}
	ormFlush();
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
