<cfscript>
cflog( text: url.marker, log: "orm" );

item = entityNew( "IsoEntity" );
item.setId( createUUID() );
item.setName( "LogsOff" );
entitySave( item );
ormFlush();

echo( "ok" );
</cfscript>
