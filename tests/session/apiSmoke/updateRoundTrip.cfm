<cfscript>
// save existing (update) → flush → loadByPK
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "original" );
entitySave( entity );
ormFlush();

entity.setName( "updated" );
entitySave( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "SmokeEntity", entity.getId() );
if ( loaded.getName() != "updated" )
	throw( message="updateRoundTrip: expected updated, got [#loaded.getName()#]" );
echo( "ok" );
</cfscript>
