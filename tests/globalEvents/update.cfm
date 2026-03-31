<cfscript>
// setup inline — need entity in session
auto = entityNew( "Auto", { id: "upd-1", make: "Lexus" } );
entitySave( auto );
ormFlush();
application.ormEventLog = [];

auto.setModel( "GX" );
entitySave( auto );
ormFlush();
echo( serializeJSON( application.ormEventLog ) );
</cfscript>
