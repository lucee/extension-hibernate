<cfscript>
// compare loaded date with dateCompare() — verify CFML comparison works regardless of Java type
original = createDate( 2025, 6, 15 );
entity = entityNew( "DateEntity" );
entity.setId( createUUID() );
entity.setDateValue( original );
entitySave( entity );
ormFlush();
entityReload( entity );

if ( dateCompare( entity.getDateValue(), original, "d" ) != 0 )
	throw( message="dateCompare: loaded date does not match original" );
echo( "ok" );
</cfscript>
