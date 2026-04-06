<cfscript>
// entitySave without forceInsert on new entity — verify ID populated after flush
entity = entityNew( "IdentityEntity" );
entity.setName( "new-save" );
entitySave( entity );
ormFlush();

if ( isNull( entity.getId() ) || entity.getId() == 0 )
	throw( message="save new entity: ID not populated after flush, got [#entity.getId()#]" );
echo( "ok" );
</cfscript>
