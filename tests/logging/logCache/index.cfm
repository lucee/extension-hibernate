<cfscript>
// write a marker so the test can find where this request's logging starts
cflog( text: url.marker, log: "orm" );

// save an entity — should produce a cache "put"
item = entityNew( "CachedItem" );
item.setId( createUUID() );
item.setName( "TestItem" );
entitySave( item );
ormFlush();

// clear session and reload — should produce a cache "hit"
ormClearSession();
loaded = entityLoadByPK( "CachedItem", item.getId() );

echo( "ok" );
</cfscript>
