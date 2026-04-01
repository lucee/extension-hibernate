<cfscript>
// write a marker so the test can find where this request's logging starts
cflog( text: url.marker, log: "orm" );

// save an entity to generate SQL + params
car = entityNew( "Auto" );
car.setId( createUUID() );
car.setMake( "Toyota" );
car.setModel( "Hilux" );
entitySave( car );
ormFlush();

echo( "ok" );
</cfscript>
