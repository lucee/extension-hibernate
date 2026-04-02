<cfscript>
// Empty collection — should return empty array/struct, not null

id = createUUID();
parent = entityNew( "ArrayParent", { id: id, name: "empty-test" } );
entitySave( parent );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "ArrayParent", id );
tags = loaded.getTags();
if ( isNull( tags ) )
	throw( message="tags should not be null for empty collection" );
if ( !isArray( tags ) )
	throw( message="tags should be an empty array" );
if ( arrayLen( tags ) != 0 )
	throw( message="expected 0 tags, got #arrayLen( tags )#" );

// Same for struct
id2 = createUUID();
parent2 = entityNew( "MapParent", { id: id2, name: "empty-map" } );
entitySave( parent2 );
ormFlush();
ormClearSession();

loaded2 = entityLoadByPK( "MapParent", id2 );
meta = loaded2.getMetadata();
if ( isNull( meta ) )
	throw( message="metadata should not be null for empty collection" );
if ( !isStruct( meta ) )
	throw( message="metadata should be an empty struct" );
if ( structCount( meta ) != 0 )
	throw( message="expected 0 keys, got #structCount( meta )#" );

echo( "ok" );
</cfscript>
