<cfscript>
// With autoManageSession=false, app must manage flushing explicitly
id = createUUID();
entity = entityNew( "AMSEntity", { id: id, name: "Manual" } );
entitySave( entity );

// without explicit flush, nothing should be in DB
row = queryExecute( "SELECT count(*) as cnt FROM AMS_Entity WHERE id = :id", { id: id } );
if ( row.cnt != 0 )
	throw( message="autoManageSession=false: entity should NOT be in DB without explicit flush, got count=#row.cnt#" );

// explicit flush should persist
ormFlush();
row2 = queryExecute( "SELECT count(*) as cnt FROM AMS_Entity WHERE id = :id", { id: id } );
if ( row2.cnt != 1 )
	throw( message="after ormFlush, entity should be in DB, got count=#row2.cnt#" );

echo( "ok" );
</cfscript>
