<cfscript>
// Test getStatistics() entity and collection counts
id1 = createUUID();
id2 = createUUID();
id3 = createUUID();

entitySave( entityNew( "SmokeEntity", { id: id1, name: "One" } ) );
entitySave( entityNew( "SmokeEntity", { id: id2, name: "Two" } ) );
entitySave( entityNew( "SmokeEntity", { id: id3, name: "Three" } ) );
ormFlush();

stats = ORMGetSession().getStatistics();
entityCount = stats.getEntityCount();
collectionCount = stats.getCollectionCount();

if ( entityCount != 3 )
	throw( message="Expected 3 entities in session, got [#entityCount#]" );

if ( collectionCount != 0 )
	throw( message="Expected 0 collections in session, got [#collectionCount#]" );

echo( "ok" );
</cfscript>
