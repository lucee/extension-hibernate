<cfscript>
// cascade="save-update" on a one-to-many: entitySave(parent) with two transient children
// attached must persist the children too (H5 contract). Asserts both rows landed in the
// child table with the right FK back to the parent.
try {
	transaction {
		parent = entityNew( "CascadeParent" );
		parent.setName( "TopParent" );

		child1 = entityNew( "CascadeChild" );
		child1.setName( "FirstChild" );
		child1.setParent( parent );

		child2 = entityNew( "CascadeChild" );
		child2.setName( "SecondChild" );
		child2.setParent( parent );

		parent.setChildren( [ child1, child2 ] );

		// only save the parent — cascade should pull the children in
		entitySave( parent );
	}
	ormFlush();
	ormClearSession();

	// confirm both children landed with FK back to parent
	rows = ormExecuteQuery(
		"FROM CascadeChild WHERE parent.id = :pid ORDER BY name",
		{ pid: parent.getId() }
	);
	if ( arrayLen( rows ) != 2 )
		throw( message="Expected 2 cascaded children, got [#arrayLen( rows )#]" );
	if ( rows[ 1 ].getName() != "FirstChild" )
		throw( message="Expected first cascaded child [FirstChild], got [#rows[ 1 ].getName()#]" );
	if ( rows[ 2 ].getName() != "SecondChild" )
		throw( message="Expected second cascaded child [SecondChild], got [#rows[ 2 ].getName()#]" );
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
