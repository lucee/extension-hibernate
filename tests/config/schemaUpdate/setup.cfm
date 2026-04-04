<cfscript>
// Phase 1: dropcreate with v1 entity (id, name)
// Insert a row so phase 2 can verify data survived the schema update

item = entityNew( "SchemaUpdateItem", { id: "row1", name: "original" } );
entitySave( item );
ormFlush();

result = queryExecute( "SELECT count(*) as cnt FROM SchemaUpdateItem" );
if ( result.cnt[ 1 ] != 1 )
	throw( message="Phase 1: expected 1 row, got [#result.cnt[ 1 ]#]" );

echo( "ok" );
</cfscript>
