<cfscript>
// Create parent, then child, then delete parent — orphan the child
pid = createUUID();
cid = createUUID();

entitySave( entityNew( "MRIParent", { id: pid, name: "Doomed" } ) );
ormFlush();

queryExecute( "INSERT INTO MRI_ChildIgnored ( id, name, parentId ) VALUES ( :id, :name, :pid )",
	{ id: cid, name: "Orphan", pid: pid } );

// disable FK checks to delete parent while child references it
queryExecute( "SET FOREIGN_KEY_CHECKS = 0" );
queryExecute( "DELETE FROM MRI_Parent WHERE id = :id", { id: pid } );
queryExecute( "SET FOREIGN_KEY_CHECKS = 1" );
ormClearSession();

// with missingRowIgnored=true, accessing the parent should return null, not throw
loaded = entityLoadByPK( "MRIChildIgnored", cid );
parent = loaded.getParent();
if ( !isNull( parent ) )
	throw( message="expected null for missing row, got object" );

echo( "ok" );
</cfscript>
