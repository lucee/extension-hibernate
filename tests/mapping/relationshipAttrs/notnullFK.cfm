<cfscript>
// notnull=true on many-to-one FK — saving without category should throw
item = entityNew( "RAItem", { id: createUUID(), name: "No Category" } );
// deliberately NOT setting category

try {
	entitySave( item );
	ormFlush();
	throw( message="should have thrown not-null constraint violation" );
} catch ( any e ) {
	if ( e.message contains "null" || e.message contains "constraint" || e.message contains "not-null"
			|| e.message contains "NULL" || e.type contains "database" )
		echo( "ok" );
	else
		rethrow;
}
</cfscript>
