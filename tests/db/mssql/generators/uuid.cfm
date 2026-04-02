<cfscript>
// generator="uuid" — Hibernate generates a 32-char hex string
e = entityNew( "UuidEntity" );
e.setName( "uuid test" );
entitySave( e );
ormFlush();

id = e.getId();
if ( isNull( id ) || len( id ) == 0 )
	throw( message="uuid: ID was not generated" );
if ( len( id ) != 32 )
	throw( message="uuid: expected 32-char hex ID, got [#id#] (len=#len( id )#)" );

ormClearSession();
loaded = entityLoadByPK( "UuidEntity", id );
if ( isNull( loaded ) )
	throw( message="uuid: entity not found after save with id [#id#]" );
if ( loaded.getName() != "uuid test" )
	throw( message="uuid: name mismatch after reload" );

// second entity gets a different UUID
e2 = entityNew( "UuidEntity" );
e2.setName( "uuid test 2" );
entitySave( e2 );
ormFlush();

if ( e2.getId() == id )
	throw( message="uuid: two entities got the same UUID" );

echo( "ok" );
</cfscript>
