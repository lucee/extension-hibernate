<cfscript>
// Verify that inherited persistent properties still work when NOT overridden
entity = entityNew( "KeepsLegacy", { id: createUUID(), name: "test", legacyCode: "ABC" } );
entitySave( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "KeepsLegacy", entity.getId() );
if ( loaded.getLegacyCode() != "ABC" )
	throw( message="expected legacyCode=ABC, got #loaded.getLegacyCode()#" );

echo( "ok" );
</cfscript>
