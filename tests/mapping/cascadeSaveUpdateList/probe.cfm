<cfscript>
// cascade list with save-update + delete-orphan. Locks down (1) the list form is
// accepted at SF build, (2) save-update cascade fires for transient children.
// delete-orphan exercise lives in dedicated tests — it requires in-place mutation
// of the children collection, which is a separate concern.
try {
	transaction {
		parent = entityNew( "ListParent" );
		parent.setName( "ListRoot" );

		child = entityNew( "ListChild" );
		child.setName( "OnlyChild" );
		child.setParent( parent );

		parent.setChildren( [ child ] );

		entitySave( parent );
	}
	ormFlush();
	ormClearSession();

	rows = ormExecuteQuery(
		"FROM ListChild WHERE parent.id = :pid",
		{ pid: parent.getId() }
	);
	if ( arrayLen( rows ) != 1 )
		throw( message="Expected 1 cascaded child, got [#arrayLen( rows )#]" );
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>

