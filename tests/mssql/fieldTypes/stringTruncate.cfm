<cfscript>
// string with length=9 should throw on values > 9 chars
sink = entityNew( "KitchenSink", { id: createUUID() } );
sink.setString( "thisisjusttoolong" );
threw = false;
try {
	entitySave( sink );
	ormFlush();
} catch ( any e ) {
	threw = true;
}
if ( !threw ) throw( message="expected exception for string exceeding length=9" );

echo( "ok" );
</cfscript>
