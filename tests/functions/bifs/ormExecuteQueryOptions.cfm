<cfscript>
for ( i = 1; i <= 5; i++ ) {
	entitySave( entityNew( "Auto", { id: createUUID(), make: "Brand#i#", model: "Model#i#" } ) );
}
ormFlush();

// maxResults
result = ormExecuteQuery( "FROM Auto", {}, false, { maxResults: 2 } );
if ( arrayLen( result ) != 2 ) throw( message="maxResults: expected 2, got #arrayLen( result )#" );

// offset
result2 = ormExecuteQuery( "FROM Auto", {}, false, { offset: 3, maxResults: 10 } );
if ( arrayLen( result2 ) != 2 ) throw( message="offset: expected 2, got #arrayLen( result2 )#" );

echo( "ok" );
</cfscript>
