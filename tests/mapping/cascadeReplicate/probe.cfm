<cfscript>
// Probe: SF builds with cascade="replicate" + basic save works.
try {
	transaction {
		parent = entityNew( "ReplicateParent" );
		parent.setId( 1 );
		parent.setName( "ReplicateRoot" );
		entitySave( parent );

		child = entityNew( "ReplicateChild" );
		child.setId( 1 );
		child.setName( "ReplicateKid" );
		child.setParent( parent );
		entitySave( child );
	}
	ormFlush();
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
