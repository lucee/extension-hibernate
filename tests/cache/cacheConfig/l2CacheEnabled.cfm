<cfscript>
// L2 cache works — entity survives DB delete + session clear
transaction {
	entity = entityNew( "CacheItem" );
	entity.setId( createUUID() );
	entity.setName( "cached-item" );
	entitySave( entity );
	ormFlush();
}

// delete directly from DB
queryExecute( "DELETE FROM CacheItem WHERE id = :id", { id: entity.getId() }, { datasource: "h2" } );

// clear first-level cache
ormClearSession();

// should still load from L2 cache
loaded = entityLoadByPK( "CacheItem", entity.getId() );
if ( isNull( loaded ) )
	throw( message="l2CacheEnabled: entity not found in L2 cache after DB delete" );
echo( "ok" );
</cfscript>
