<cfscript>
// Array (bag) collection — basic CRUD round-trip

// Create via ORM
id = createUUID();
parent = entityNew( "ArrayParent", { id: id, name: "array-test" } );
entitySave( parent );
ormFlush();

// Insert collection rows via SQL (collection tables aren't managed by entitySave)
queryExecute( "INSERT INTO COL_ArrayTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "cfml" } );
queryExecute( "INSERT INTO COL_ArrayTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "orm" } );
queryExecute( "INSERT INTO COL_ArrayTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "hibernate" } );

ormClearSession();

// Load and verify
loaded = entityLoadByPK( "ArrayParent", id );
if ( loaded.getName() != "array-test" )
	throw( message="name: expected array-test, got #loaded.getName()#" );

tags = loaded.getTags();
if ( !isArray( tags ) )
	throw( message="tags should be an array" );
if ( arrayLen( tags ) != 3 )
	throw( message="expected 3 tags, got #arrayLen( tags )#" );

// Verify values present (order not guaranteed in bag)
tagList = arrayToList( tags );
if ( !listFindNoCase( tagList, "cfml" ) )
	throw( message="missing tag 'cfml' in: #tagList#" );
if ( !listFindNoCase( tagList, "orm" ) )
	throw( message="missing tag 'orm' in: #tagList#" );
if ( !listFindNoCase( tagList, "hibernate" ) )
	throw( message="missing tag 'hibernate' in: #tagList#" );

echo( "ok" );
</cfscript>
