<cfscript>
// With flushAtRequestEnd=true, entitySave without explicit ormFlush
// should persist at end of request. We verify by checking the DB
// in a SECOND request (this template is the setup request).
id = url.testId ?: createUUID();
action = url.action ?: "save";

if ( action == "save" ) {
	entity = entityNew( "AutoFlush", { id: id, name: "AutoSaved" } );
	entitySave( entity );
	// deliberately NOT calling ormFlush()
	echo( "saved:#id#" );
} else if ( action == "verify" ) {
	// check if the entity persisted from the previous request
	row = queryExecute( "SELECT count(*) as cnt FROM AF_Entity WHERE id = :id", { id: id } );
	echo( "count:#row.cnt#" );
}
</cfscript>
