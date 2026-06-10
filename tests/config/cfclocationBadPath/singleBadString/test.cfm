<cfscript>
// cfclocation set to a single string pointing at a nonexistent directory.
// loadResources splits to a single-element array, that entry drops, empty list,
// falls back to defaultCFCLocation. DefaultEntity.cfc lives here, must still load.

ent = entityNew( "DefaultEntity", { id: createUUID(), label: "single-bad-string-ok" } );
entitySave( ent );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM DefaultEntity" );
if ( result.cnt[ 1 ] != 1 )
	throw( message="Expected 1 DefaultEntity row, got [#result.cnt[ 1 ]#]" );

errCaught = false;
errMsg    = "";
try {
	entityNew( "DoesNotExist", { id: createUUID() } );
}
catch ( any e ) {
	errCaught = true;
	errMsg    = e.message;
}

if ( !errCaught )
	throw( message="Expected entityNew('DoesNotExist') to throw, but it did not" );

systemOutput( "[singleBadString] DoesNotExist message=[#left( errMsg, 200 )#]", true );

echo( "ok" );
</cfscript>
