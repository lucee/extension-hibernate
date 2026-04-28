<cfscript>
try {
	transaction {
		parent = entityNew( "RefreshParent" );
		parent.setName( "RefreshRoot" );
		entitySave( parent );

		child = entityNew( "RefreshChild" );
		child.setName( "RefreshKid" );
		child.setParent( parent );
		entitySave( child );
	}
	ormFlush();
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
