<cfscript>
// save now(), reload, verify isDate()
entity = entityNew( "DateEntity" );
entity.setId( createUUID() );
entity.setDateValue( now() );
entitySave( entity );
ormFlush();
entityReload( entity );

if ( !isDate( entity.getDateValue() ) )
	throw( message="dateNow: loaded value is not a date" );
echo( "ok" );
</cfscript>
