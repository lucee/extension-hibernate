<cfscript>
// cfclocation = [ goodPath, badPath ]. badPath silently dropped, goodPath kept.
// GoodEntity from goodPath must load. Unknown entity must fail.

ent = entityNew( "GoodEntity", { id: createUUID(), label: "mixed-good" } );
entitySave( ent );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM GoodEntity" );
if ( result.cnt[ 1 ] != 1 )
	throw( message="Expected 1 GoodEntity row, got [#result.cnt[ 1 ]#]" );

// Verify the user-set cfclocation still appears in metadata (Plan J should not change this either)
metaLocations = getApplicationMetadata().ormSettings.cfclocation;
if ( !isArray( metaLocations ) || arrayLen( metaLocations ) != 2 )
	throw( message="Expected getApplicationMetadata().ormSettings.cfclocation to have 2 entries, got [#serializeJSON( metaLocations )#]" );

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

systemOutput( "[mixed] DoesNotExist message=[#left( errMsg, 200 )#]", true );

echo( "ok" );
</cfscript>
