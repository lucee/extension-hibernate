<cfscript>
// save new → flush → loadByPK round-trip
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "round-trip" );
entitySave( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "SmokeEntity", entity.getId() );
if ( isNull( loaded ) )
	throw( message="saveLoad: entity not found after save+flush" );
if ( loaded.getName() != "round-trip" )
	throw( message="saveLoad: expected round-trip, got [#loaded.getName()#]" );
echo( "ok" );
</cfscript>
