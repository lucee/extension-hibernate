<cfscript>
// With skipCFCWithError=true, the broken entity should be skipped
// but the good entity should still work
id = createUUID();
entity = entityNew( "GoodEntity", { id: id, name: "Works" } );
entitySave( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "GoodEntity", id );
if ( loaded.getName() != "Works" )
	throw( message="expected Works, got #loaded.getName()#" );

// verify the broken entity was skipped (not in entity list)
names = entityNameArray();
for ( n in names ) {
	if ( n == "BrokenEntity" )
		throw( message="BrokenEntity should have been skipped" );
}

echo( "ok" );
</cfscript>
