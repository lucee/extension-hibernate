<cfscript>
cflog( text: url.marker, log: "orm" );

item = entityNew( "LogEntity" );
item.setId( createUUID() );
item.setName( "ErrorTest" );
entitySave( item );
ormFlush();

echo( "ok" );
</cfscript>
