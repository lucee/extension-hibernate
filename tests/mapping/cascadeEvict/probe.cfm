<cfscript>
// `cascade="evict"` was a valid H5 cascade style. Removed in Hibernate 6+.
// Probe: SF builds and entityNew/entitySave run cleanly under H5.
try {
	parent = entityNew( "EvictParent" );
	parent.setName( "EvictRoot" );

	child = entityNew( "EvictChild" );
	child.setName( "EvictKid" );
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
