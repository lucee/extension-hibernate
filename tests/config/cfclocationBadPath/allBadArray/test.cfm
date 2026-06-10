<cfscript>
// All cfclocation entries point to nonexistent paths.
// loadResources silently drops them -> empty list -> _load falls back to defaultCFCLocation
// (the parent dir of this template). DefaultEntity.cfc lives here, so it must still load.

ent = entityNew( "DefaultEntity", { id: createUUID(), label: "fallback-ok" } );
entitySave( ent );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM DefaultEntity" );
if ( result.cnt[ 1 ] != 1 )
	throw( message="Expected 1 DefaultEntity row, got [#result.cnt[ 1 ]#]" );

// Entity inside one of the (nonexistent) bad-path directories cannot exist.
// Asking for an unknown entity must fail; capture the current error text so Plan J's
// lazy resolution can be verified to preserve the user-visible failure message.
errCaught = false;
errType   = "";
errMsg    = "";
try {
	entityNew( "DoesNotExist", { id: createUUID() } );
}
catch ( any e ) {
	errCaught = true;
	errType   = e.type;
	errMsg    = e.message;
}

if ( !errCaught )
	throw( message="Expected entityNew('DoesNotExist') to throw, but it did not" );

// Pin the current behaviour: missing entity surfaces as an ORM/Hibernate error.
// Plan J must preserve this user-visible failure mode.
systemOutput( "[allBadArray] DoesNotExist error type=[#errType#] message=[#left( errMsg, 200 )#]", true );

echo( "ok" );
</cfscript>
