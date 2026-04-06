<cfscript>
// verify ORM session is available and functional during request
// ormGetSession() returns a Lucee struct wrapper; just verify it's usable
ormSess = ormGetSession();
if ( isNull( ormSess ) )
	throw( message="sessionIsOpen: ormGetSession() returned null" );
// verify we can use it to do a basic operation
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "open-test" );
entitySave( entity );
ormFlush();
echo( "ok" );
</cfscript>
