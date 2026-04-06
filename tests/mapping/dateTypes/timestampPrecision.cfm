<cfscript>
// save timestamp with full date+time precision
ts = createDateTime( 2025, 12, 25, 10, 30, 45 );
entity = entityNew( "DateEntity" );
entity.setId( createUUID() );
entity.setTimestampValue( ts );
entitySave( entity );
ormFlush();
entityReload( entity );

loaded = entity.getTimestampValue();
if ( !isDate( loaded ) )
	throw( message="timestampPrecision: loaded value is not a date" );
if ( year( loaded ) != 2025 || month( loaded ) != 12 || day( loaded ) != 25 )
	throw( message="timestampPrecision: date portion mismatch" );
if ( hour( loaded ) != 10 || minute( loaded ) != 30 || second( loaded ) != 45 )
	throw( message="timestampPrecision: time portion mismatch" );
echo( "ok" );
</cfscript>
