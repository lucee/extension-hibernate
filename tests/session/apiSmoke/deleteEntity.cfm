<cfscript>
// delete → flush → loadByPK returns null
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "to-delete" );
entitySave( entity );
ormFlush();

entityDelete( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "SmokeEntity", entity.getId() );
if ( !isNull( loaded ) )
	throw( message="deleteEntity: entity still exists after delete+flush" );
echo( "ok" );
</cfscript>
