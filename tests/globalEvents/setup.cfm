<cfscript>
// Insert a baseline entity for tests that need one
auto = entityNew( "Auto", { id: "test-1", make: "Lexus" } );
entitySave( auto );
ormFlush();
// Reset the log after setup
application.ormEventLog = [];
echo( serializeJSON( { id: auto.getId() } ) );
</cfscript>
