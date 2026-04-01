<cfscript>
entitySave( entityNew( "Auto", { id: createUUID(), make: "BMW" } ) );
ormFlush();
echo( serializeJSON( application.ormEventLog ) );
</cfscript>
