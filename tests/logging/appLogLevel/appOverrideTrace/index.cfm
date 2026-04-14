<cfscript>
cflog( text: url.marker, log: "orm" );

item = entityNew( "LogEntity" );
item.setId( createUUID() );
item.setName( "TraceTest" );
entitySave( item );
ormFlush();

echo( "ok" );
</cfscript>
