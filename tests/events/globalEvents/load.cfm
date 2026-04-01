<cfscript>
auto = entityNew( "Auto", { id: "load-1", make: "Lexus" } );
entitySave( auto );
ormFlush();
ormClearSession();
application.ormEventLog = [];

// Load from DB — should trigger preLoad/postLoad
entityLoad( "Auto", auto.getId() );
echo( serializeJSON( application.ormEventLog ) );
</cfscript>
