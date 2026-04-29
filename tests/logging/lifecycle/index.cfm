<cfscript>
if ( structKeyExists( url, "marker" ) ) {
	cflog( text: url.marker, log: "orm" );
	car = entityNew( "Auto" );
	car.setId( createUUID() );
	car.setMake( "Toyota" );
	car.setModel( "Hilux" );
	entitySave( car );
	ormFlush();
}
echo( "ok" );
</cfscript>
