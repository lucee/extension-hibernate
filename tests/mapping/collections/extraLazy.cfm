<cfscript>
// Array collection with lazy="extra" — extra-lazy doesn't init full collection on size()

id = createUUID();
queryExecute( "INSERT INTO COL_ExtraLazy (id, name) VALUES (:id, :name)", { id: id, name: "extra" } );
queryExecute( "INSERT INTO COL_ExtraLazyTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "one" } );
queryExecute( "INSERT INTO COL_ExtraLazyTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "two" } );
queryExecute( "INSERT INTO COL_ExtraLazyTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "three" } );

ormClearSession();

parent = entityLoadByPK( "ExtraLazyParent", id );

// With extra-lazy, the collection should still be accessible within the session
tags = parent.getTags();
if ( arrayLen( tags ) != 3 )
	throw( message="expected 3 tags, got #arrayLen( tags )#" );

echo( "ok" );
</cfscript>
