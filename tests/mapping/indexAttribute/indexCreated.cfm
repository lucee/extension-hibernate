<cfscript>
// Save entity to ensure table is created
entitySave( entityNew( "Indexed", { id: createUUID(), email: "test@test.com" } ) );
ormFlush();

// Verify index exists via INFORMATION_SCHEMA
indexes = queryExecute(
	"SELECT INDEX_NAME FROM INFORMATION_SCHEMA.INDEXES WHERE TABLE_NAME = 'IX_INDEXED' AND INDEX_NAME = 'IDX_EMAIL'"
);
if ( indexes.recordCount == 0 )
	throw( message="expected IDX_EMAIL index to exist" );

echo( "ok" );
</cfscript>
