<cfscript>
// direct session flush via ormGetSession()
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "session-flush" );
entitySave( entity );
ormGetSession().flush();
ormClearSession();

loaded = entityLoadByPK( "SmokeEntity", entity.getId() );
if ( isNull( loaded ) )
	throw( message="sessionFlush: entity not found after session.flush()" );
echo( "ok" );
</cfscript>
