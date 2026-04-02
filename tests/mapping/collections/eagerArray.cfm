<cfscript>
// Array collection with lazy="false" — proves eager loading

id = createUUID();
queryExecute( "INSERT INTO COL_EagerArray (id, name) VALUES (:id, :name)", { id: id, name: "eager" } );
queryExecute( "INSERT INTO COL_EagerArrayTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "alpha" } );
queryExecute( "INSERT INTO COL_EagerArrayTags (parentId, tag) VALUES (:id, :tag)", { id: id, tag: "beta" } );

ormClearSession();

// Load entity
parent = entityLoadByPK( "EagerArrayParent", id );

// Close session — if lazy="false" worked, collection is already loaded
ormClearSession();

// Access after session close — should NOT throw LazyInitializationException
tags = parent.getTags();
if ( !isArray( tags ) )
	throw( message="tags should be an array" );
if ( arrayLen( tags ) != 2 )
	throw( message="expected 2 tags, got #arrayLen( tags )#" );

echo( "ok" );
</cfscript>
