<cfscript>
deptId = createUUID();
queryExecute( "INSERT INTO WF_Department ( id, name ) VALUES ( :id, :name )",
	{ id: deptId, name: "Engineering" } );
queryExecute( "INSERT INTO WF_Staff ( id, name, is_active, deptId ) VALUES ( :id, :name, :active, :did )",
	{ id: createUUID(), name: "Alice", active: true, did: deptId } );
queryExecute( "INSERT INTO WF_Staff ( id, name, is_active, deptId ) VALUES ( :id, :name, :active, :did )",
	{ id: createUUID(), name: "Bob", active: true, did: deptId } );
queryExecute( "INSERT INTO WF_Staff ( id, name, is_active, deptId ) VALUES ( :id, :name, :active, :did )",
	{ id: createUUID(), name: "Charlie", active: false, did: deptId } );

ormClearSession();

dept = entityLoadByPK( "Department", deptId );
staff = dept.getActiveStaff();
if ( arrayLen( staff ) != 2 )
	throw( message="expected 2 active staff, got #arrayLen( staff )#" );

echo( "ok" );
</cfscript>
