<cfscript>
auto = entityNew( "Auto", { id: "del-1", make: "Lexus" } );
entitySave( auto );
ormFlush();
application.ormEventLog = [];

entityDelete( auto );
ormFlush();
echo( serializeJSON( application.ormEventLog ) );
</cfscript>
