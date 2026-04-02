<cfscript>
// Struct collection with lazy="false" — proves eager loading on map type

id = createUUID();
queryExecute( "INSERT INTO COL_EagerMap (id, name) VALUES (:id, :name)", { id: id, name: "eager-map" } );
queryExecute( "INSERT INTO COL_EagerMapMeta (parentId, metaKey, metaValue) VALUES (:id, :k, :v)",
	{ id: id, k: "env", v: "prod" } );

ormClearSession();

// Load entity
parent = entityLoadByPK( "EagerMapParent", id );

// Close session — if lazy="false" worked, collection is already loaded
ormClearSession();

// Access after session close
meta = parent.getMetadata();
if ( !isStruct( meta ) )
	throw( message="metadata should be a struct" );
if ( meta[ "env" ] != "prod" )
	throw( message="env: expected prod, got #meta[ 'env' ]#" );

echo( "ok" );
</cfscript>
