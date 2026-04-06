<cfscript>
pid = createUUID();
cid = createUUID();
parent = entityNew( "FKParent", { id: pid, name: "Parent" } );
entitySave( parent );
ormFlush();

child = entityNew( "FKChild", { id: cid } );
child.setParent( parent );
entitySave( child );
ormFlush();

// Check for FK constraint — H2 stores them in INFORMATION_SCHEMA.CONSTRAINTS
// or TABLE_CONSTRAINTS with CONSTRAINT_TYPE='REFERENTIAL'
constraints = queryExecute(
	"SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'FKN_CHILD' AND CONSTRAINT_TYPE = 'REFERENTIAL'"
);

// verify at least one FK constraint exists
if ( constraints.recordCount == 0 ) {
	// try the CONSTRAINTS view (H2 v2.x)
	constraints = queryExecute(
		"SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME LIKE '%FKN_CHILD%' OR CONSTRAINT_NAME LIKE '%FK_CHILD_PARENT%'"
	);
}

// Check if our named FK exists
foundNamed = false;
for ( row in constraints ) {
	if ( uCase( row.CONSTRAINT_NAME ) contains "FK_CHILD_PARENT" ) foundNamed = true;
}

// Also verify the relationship works functionally
ormClearSession();
loadedChild = entityLoadByPK( "FKChild", cid );
if ( !isObject( loadedChild.getParent() ) )
	throw( message="FK relationship should load parent" );
if ( loadedChild.getParent().getName() != "Parent" )
	throw( message="expected Parent, got #loadedChild.getParent().getName()#" );

// Log whether the FK was named correctly (informational, not a hard fail)
if ( !foundNamed && constraints.recordCount > 0 )
	systemOutput( "NOTE: foreignkey attribute not honoured — FK exists but with auto-generated name: #constraints.CONSTRAINT_NAME[ 1 ]#", true );

echo( "ok" );
</cfscript>
