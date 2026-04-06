<cfscript>
// Verify session is open and tracks entities after CRUD operations.
// Note: in Lucee, ORMGetSession() always returns an open session (creates on demand).
// The Adobe docs' claim that "session starts on first CRUD call" is not directly
// testable — ORMGetSession() itself triggers session creation. What we CAN verify
// is that the session is functional and tracks saved entities.

ormSess = ORMGetSession();
if ( !ormSess.isOpen() )
	throw( message="session should be open after ORMGetSession" );

// save an entity — session should track it
id = createUUID();
entity = entityNew( "SmokeEntity", { id: id, name: "SessionTest" } );
entitySave( entity );

ormSess2 = ORMGetSession();
if ( !ormSess2.contains( entity ) )
	throw( message="session should contain saved entity" );

ormFlush();

echo( "ok" );
</cfscript>
