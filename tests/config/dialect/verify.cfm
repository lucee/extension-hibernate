<cfscript>
// verify ORM initialised and basic entityLoad works
entity = entityNew( "DialectEntity" );
entity.setId( createUUID() );
entity.setName( "dialect-test" );
entitySave( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "DialectEntity", entity.getId() );
if ( isNull( loaded ) )
	throw( message="dialect verify: entity not found after save" );
if ( loaded.getName() != "dialect-test" )
	throw( message="dialect verify: expected dialect-test, got [#loaded.getName()#]" );
echo( "ok" );
</cfscript>
