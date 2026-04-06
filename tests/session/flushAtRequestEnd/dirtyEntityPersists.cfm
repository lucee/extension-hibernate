<cfscript>
// With flushAtRequestEnd=true, modifying a loaded entity WITHOUT calling
// entitySave or ormFlush should still persist the change (dirty checking).
// This is the "gotcha" behaviour we document.
id = url.testId ?: createUUID();
action = url.action ?: "setup";

if ( action == "setup" ) {
	entity = entityNew( "AutoFlush", { id: id, name: "Original" } );
	entitySave( entity );
	ormFlush();
	echo( "setup:#id#" );
} else if ( action == "mutate" ) {
	// load and mutate — no save, no flush
	entity = entityLoadByPK( "AutoFlush", id );
	entity.setName( "Mutated" );
	// request ends here — flushAtRequestEnd should persist this
	echo( "mutated" );
} else if ( action == "verify" ) {
	row = queryExecute( "SELECT name FROM AF_Entity WHERE id = :id", { id: id } );
	echo( "name:#row.name#" );
}
</cfscript>
