<cfscript>
// merge detached entity → flush → verify
entity = entityNew( "SmokeEntity" );
entity.setId( createUUID() );
entity.setName( "before-merge" );
entitySave( entity );
ormFlush();

ormClearSession(); // detach all entities
entity.setName( "after-merge" );
merged = entityMerge( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "SmokeEntity", entity.getId() );
if ( loaded.getName() != "after-merge" )
	throw( message="mergeDetached: expected after-merge, got [#loaded.getName()#]" );
echo( "ok" );
</cfscript>
