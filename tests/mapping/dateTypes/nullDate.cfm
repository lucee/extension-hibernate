<cfscript>
// save null date, reload, verify null
entity = entityNew( "DateEntity" );
entity.setId( createUUID() );
// leave dateValue null
entitySave( entity );
ormFlush();
entityReload( entity );

if ( !isNull( entity.getDateValue() ) )
	throw( message="nullDate: expected null, got #entity.getDateValue()#" );
echo( "ok" );
</cfscript>
