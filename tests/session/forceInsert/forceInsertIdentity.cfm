<cfscript>
// forceInsert with generator=identity — verify ID populated after flush
entity = entityNew( "IdentityEntity" );
entity.setName( "test" );
entitySave( entity, true );
ormFlush();

if ( isNull( entity.getId() ) || entity.getId() == 0 )
	throw( message="forceInsert identity: ID not populated after flush, got [#entity.getId()#]" );
echo( "ok" );
</cfscript>
