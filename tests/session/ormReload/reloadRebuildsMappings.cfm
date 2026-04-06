<cfscript>
// Verify ORMReload rebuilds mappings and entities are still functional after
id = createUUID();
entity = entityNew( "ReloadEntity", { id: id, name: "Before" } );
entitySave( entity );
ormFlush();

// reload ORM — this should close sessions, rebuild all mappings
ormReload();

// after reload, we should be able to create and persist new entities
id2 = createUUID();
entity2 = entityNew( "ReloadEntity", { id: id2, name: "After" } );
entitySave( entity2 );
ormFlush();

// verify the post-reload entity specifically exists
row = queryExecute( "SELECT count(*) as cnt FROM RL_Entity WHERE id = :id", { id: id2 } );
if ( row.cnt != 1 )
	throw( message="post-reload entity should exist, got count=#row.cnt#" );

// verify entity list still works
names = entityNameArray();
found = false;
for ( n in names ) {
	if ( n == "ReloadEntity" ) found = true;
}
if ( !found )
	throw( message="ReloadEntity should be in entityNameArray after reload" );

echo( "ok" );
</cfscript>
