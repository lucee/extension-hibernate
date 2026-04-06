<cfscript>
// save specific date, reload, verify year/month/day
entity = entityNew( "DateEntity" );
entity.setId( createUUID() );
entity.setDateValue( createDate( 2025, 6, 15 ) );
entitySave( entity );
ormFlush();
entityReload( entity );

if ( year( entity.getDateValue() ) != 2025 )
	throw( message="dateSpecific: expected year 2025, got #year( entity.getDateValue() )#" );
if ( month( entity.getDateValue() ) != 6 )
	throw( message="dateSpecific: expected month 6, got #month( entity.getDateValue() )#" );
if ( day( entity.getDateValue() ) != 15 )
	throw( message="dateSpecific: expected day 15, got #day( entity.getDateValue() )#" );
echo( "ok" );
</cfscript>
