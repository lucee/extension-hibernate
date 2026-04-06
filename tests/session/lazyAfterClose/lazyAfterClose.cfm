<cfscript>
// The #1 ORM error: "could not initialize proxy - no Session"
// Accessing a lazy collection after closing the session should throw
pid = createUUID();
parent = entityNew( "LazyParent", { id: pid, name: "Parent" } );
entitySave( parent );
ormFlush();
queryExecute( "INSERT INTO LAC_Child (id, name, parentId) VALUES (:id, :name, :pid)",
	{ id: createUUID(), name: "Child1", pid: pid } );
ormClearSession();

// load parent — children are lazy, not yet loaded
loaded = entityLoadByPK( "LazyParent", pid );

// close the session
ormCloseSession();

// now try to access the lazy collection — this should fail
try {
	children = loaded.getChildren();
	// if we get here, it might have loaded eagerly or the session wasn't truly closed
	// some implementations may throw on iteration instead of access
	if ( isArray( children ) ) {
		len = arrayLen( children );
	}
	// no error — Lucee may open a new session on lazy access, or the collection was empty
	systemOutput( "NOTE: lazy access after ormCloseSession did NOT throw. Got #len# children. This means Lucee re-opens the session on demand.", true );
	echo( "no-error:#len#" );
} catch ( any e ) {
	if ( e.message contains "Session" || e.message contains "session" || e.message contains "proxy"
			|| e.message contains "initialize" || e.message contains "closed" || e.message contains "no longer" )
		echo( "ok" );
	else
		rethrow;
}
</cfscript>
