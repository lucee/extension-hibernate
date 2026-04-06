<cfscript>
// entitySave on existing entity (update path) — verify ID unchanged
entity = entityNew( "IdentityEntity" );
entity.setName( "original" );
entitySave( entity );
ormFlush();

originalId = entity.getId();
entity.setName( "updated" );
entitySave( entity );
ormFlush();

if ( entity.getId() != originalId )
	throw( message="update existing: expected ID #originalId#, got #entity.getId()#" );

// verify update persisted
ormClearSession();
loaded = entityLoadByPK( "IdentityEntity", originalId );
if ( loaded.getName() != "updated" )
	throw( message="update existing: expected name updated, got #loaded.getName()#" );
echo( "ok" );
</cfscript>
