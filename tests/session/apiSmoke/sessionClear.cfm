<cfscript>
// direct session clear via ormGetSession()
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "session-clear" );
entitySave( entity );
ormFlush();

ormGetSession().clear();

// after clear, loading same PK should hit DB
loaded = entityLoadByPK( "SmokeEntity", entity.getId() );
if ( isNull( loaded ) )
	throw( message="sessionClear: entity not found after session.clear()" );
echo( "ok" );
</cfscript>
