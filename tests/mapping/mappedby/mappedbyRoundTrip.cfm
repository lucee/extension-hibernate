<cfscript>
// One-to-one unique FK association using mappedby
// MBOffice.employee uses mappedby="office" to reference MBEmployee.office property
// MBEmployee.office uses fkcolumn="officeId" to hold the FK
oid = createUUID();
eid = createUUID();

office = entityNew( "MBOffice", { id: oid, location: "Building A" } );
entitySave( office );
ormFlush();

emp = entityNew( "MBEmployee", { id: eid, name: "Alice", office: office } );
entitySave( emp );
ormFlush();
ormClearSession();

// load from the mappedby side — Office should resolve Employee via mappedby
loadedOffice = entityLoadByPK( "MBOffice", oid );
if ( !isObject( loadedOffice.getEmployee() ) )
	throw( message="mappedby should resolve the employee from the office side" );
if ( loadedOffice.getEmployee().getName() != "Alice" )
	throw( message="expected Alice, got #loadedOffice.getEmployee().getName()#" );

// load from the FK side — Employee should resolve Office via fkcolumn
loadedEmp = entityLoadByPK( "MBEmployee", eid );
if ( !isObject( loadedEmp.getOffice() ) )
	throw( message="fkcolumn should resolve the office from the employee side" );
if ( loadedEmp.getOffice().getLocation() != "Building A" )
	throw( message="expected Building A, got #loadedEmp.getOffice().getLocation()#" );

echo( "ok" );
</cfscript>
