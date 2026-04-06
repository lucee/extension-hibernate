<cfscript>
// Table-per-subclass (joined): save Employee, load as Person
empId = createUUID();
emp = entityNew( "Employee", { id: empId, name: "Alice", salary: 85000.00 } );
entitySave( emp );
ormFlush();
ormClearSession();

// load via base type
loaded = entityLoadByPK( "Person", empId );
if ( !isObject( loaded ) )
	throw( message="should load person by PK" );
if ( loaded.getName() != "Alice" )
	throw( message="expected Alice, got #loaded.getName()#" );

// should be Employee with salary
if ( getMetadata( loaded ).name does not contain "Employee" )
	throw( message="expected Employee type, got #getMetadata( loaded ).name#" );
if ( loaded.getSalary() != 85000.00 )
	throw( message="expected 85000, got #loaded.getSalary()#" );

// verify both tables exist
personTable = queryExecute( "SELECT count(*) as cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TPS_PERSON'" );
empTable = queryExecute( "SELECT count(*) as cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TPS_EMPLOYEE'" );
if ( personTable.cnt != 1 || empTable.cnt != 1 )
	throw( message="expected both TPS_Person and TPS_Employee tables to exist" );

echo( "ok" );
</cfscript>
