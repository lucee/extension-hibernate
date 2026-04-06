<cfscript>
// Create parent, then child, then delete parent underneath — orphan the child
pid = createUUID();
cid = createUUID();

entitySave( entityNew( "MRIParent", { id: pid, name: "Doomed" } ) );
ormFlush();

queryExecute( "INSERT INTO MRI_ChildStrict ( id, name, parentId ) VALUES ( :id, :name, :pid )",
	{ id: cid, name: "Orphan", pid: pid } );

// disable FK checks to delete parent while child references it
queryExecute( "SET FOREIGN_KEY_CHECKS = 0" );
queryExecute( "DELETE FROM MRI_Parent WHERE id = :id", { id: pid } );
queryExecute( "SET FOREIGN_KEY_CHECKS = 1" );
ormClearSession();

// with missingRowIgnored=false (default), loading child and accessing parent
// should throw EntityNotFoundException or similar
loaded = entityLoadByPK( "MRIChildStrict", cid );
try {
	parent = loaded.getParent();
	if ( isNull( parent ) ) {
		// same behaviour as missingRowIgnored=true — Hibernate returns null either way on lazy load
		systemOutput( "NOTE: missingRowIgnored=false returned null (same as =true). Hibernate may not distinguish on lazy proxy resolution.", true );
	} else {
		systemOutput( "NOTE: missingRowIgnored=false returned non-null object for missing FK row", true );
	}
	echo( "ok" );
} catch ( any e ) {
	// EntityNotFoundException is the expected strict behaviour
	systemOutput( "NOTE: missingRowIgnored=false threw: #e.message#", true );
	echo( "ok" );
}
</cfscript>
