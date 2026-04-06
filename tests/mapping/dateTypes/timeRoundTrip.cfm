<cfscript>
// save time, reload, verify hour/minute
entity = entityNew( "DateEntity" );
entity.setId( createUUID() );
entity.setTimeValue( createTime( 14, 30, 0 ) );
entitySave( entity );
ormFlush();
entityReload( entity );

if ( hour( entity.getTimeValue() ) != 14 )
	throw( message="timeRoundTrip: expected hour 14, got #hour( entity.getTimeValue() )#" );
if ( minute( entity.getTimeValue() ) != 30 )
	throw( message="timeRoundTrip: expected minute 30, got #minute( entity.getTimeValue() )#" );
echo( "ok" );
</cfscript>
