<cfscript>
// verify entity is managed after save — entityReload works on managed entities
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "contains-check" );
entitySave( entity );
ormFlush();

// entityReload only works on managed (attached) entities
entityReload( entity );
if ( entity.getName() != "contains-check" )
	throw( message="sessionContains: reload failed, entity not managed after save" );
echo( "ok" );
</cfscript>
