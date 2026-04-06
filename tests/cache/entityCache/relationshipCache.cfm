<cfscript>
pid = createUUID();
parent = entityNew( "CachedParent", { id: pid, name: "Parent" } );
entitySave( parent );
ormFlush();

queryExecute( "INSERT INTO EC_Item ( id, name, parentId ) VALUES ( :id, :name, :pid )",
	{ id: createUUID(), name: "Item 1", pid: pid } );
queryExecute( "INSERT INTO EC_Item ( id, name, parentId ) VALUES ( :id, :name, :pid )",
	{ id: createUUID(), name: "Item 2", pid: pid } );
ormClearSession();

loaded = entityLoadByPK( "CachedParent", pid );
items = loaded.getItems();
if ( arrayLen( items ) != 2 )
	throw( message="expected 2 items, got #arrayLen( items )#" );

echo( "ok" );
</cfscript>
