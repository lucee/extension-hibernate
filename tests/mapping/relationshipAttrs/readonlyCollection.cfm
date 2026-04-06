<cfscript>
// readonly=true on one-to-many — collection loads but can't be modified via ORM
catId = createUUID();
entitySave( entityNew( "RACategory", { id: catId, name: "Books" } ) );
ormFlush();

queryExecute( "INSERT INTO RA_Item ( id, name, categoryId ) VALUES ( :id, :name, :cid )",
	{ id: createUUID(), name: "Item 1", cid: catId } );
queryExecute( "INSERT INTO RA_Item ( id, name, categoryId ) VALUES ( :id, :name, :cid )",
	{ id: createUUID(), name: "Item 2", cid: catId } );
ormClearSession();

loaded = entityLoadByPK( "RACategory", catId );
items = loaded.getItems();
if ( arrayLen( items ) != 2 )
	throw( message="expected 2 items, got #arrayLen( items )#" );

echo( "ok" );
</cfscript>
