<cfscript>
// save entity, reload ORM, verify data survives (dropcreate will wipe it, but ormReload shouldn't throw)
auto = entityNew( "Auto", { id: createUUID(), make: "Toyota" } );
entitySave( auto );
ormFlush();

// ormReload should not throw
ormReload();

// after reload we should be able to use ORM again
auto2 = entityNew( "Auto", { id: createUUID(), make: "Honda" } );
entitySave( auto2 );
ormFlush();

echo( "ok" );
</cfscript>
