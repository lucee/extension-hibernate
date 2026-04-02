<cfscript>
// Struct (map) collection — basic CRUD round-trip

id = createUUID();
parent = entityNew( "MapParent", { id: id, name: "map-test" } );
entitySave( parent );
ormFlush();

// Insert collection rows via SQL
queryExecute( "INSERT INTO COL_MapMeta (parentId, metaKey, metaValue) VALUES (:id, :k, :v)",
	{ id: id, k: "colour", v: "blue" } );
queryExecute( "INSERT INTO COL_MapMeta (parentId, metaKey, metaValue) VALUES (:id, :k, :v)",
	{ id: id, k: "size", v: "large" } );

ormClearSession();

// Load and verify
loaded = entityLoadByPK( "MapParent", id );
meta = loaded.getMetadata();
if ( !isStruct( meta ) )
	throw( message="metadata should be a struct, got #getMetaData( meta ).getName()#" );
if ( structCount( meta ) != 2 )
	throw( message="expected 2 keys, got #structCount( meta )#" );
if ( meta[ "colour" ] != "blue" )
	throw( message="colour: expected blue, got #meta[ 'colour' ]#" );
if ( meta[ "size" ] != "large" )
	throw( message="size: expected large, got #meta[ 'size' ]#" );

echo( "ok" );
</cfscript>
