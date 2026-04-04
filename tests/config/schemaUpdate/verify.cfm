<cfscript>
// Phase 2: dbcreate=update with v2 entity (id, name, description)
// Verify: new column added, old data preserved, new property works

// Old row should still be there
loaded = entityLoadByPK( "SchemaUpdateItem", "row1" );
if ( isNull( loaded ) )
	throw( message="Phase 2: row1 from phase 1 not found — data lost during schema update" );
if ( loaded.getName() != "original" )
	throw( message="Phase 2: expected name [original], got [#loaded.getName()#]" );

// New column should be usable via ORM
loaded.setDescription( "updated" );
entitySave( loaded );
ormFlush();

reloaded = entityLoadByPK( "SchemaUpdateItem", "row1" );
if ( reloaded.getDescription() != "updated" )
	throw( message="Phase 2: expected description [updated], got [#reloaded.getDescription()#]" );

// New row with all columns should work
item2 = entityNew( "SchemaUpdateItem", { id: "row2", name: "new", description: "fresh" } );
entitySave( item2 );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM SchemaUpdateItem" );
if ( result.cnt[ 1 ] != 2 )
	throw( message="Phase 2: expected 2 rows, got [#result.cnt[ 1 ]#]" );

echo( "ok" );
</cfscript>
