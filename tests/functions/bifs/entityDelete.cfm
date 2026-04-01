<cfscript>
id = createUUID();
auto = entityNew( "Auto", { id: id, make: "Toyota", model: "Camry" } );
entitySave( auto );
ormFlush();

result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 ) throw( message="expected 1 row before delete, got #result.recordCount#" );

entityDelete( auto );
ormFlush();

result2 = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result2.recordCount != 0 ) throw( message="expected 0 rows after delete, got #result2.recordCount#" );

echo( "ok" );
</cfscript>
