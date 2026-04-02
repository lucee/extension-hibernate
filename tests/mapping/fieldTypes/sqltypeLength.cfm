<cfscript>
// Test that sqltype="varchar" with length="50" produces a varchar(50) column
// and sqltype="nvarchar" with length="100" produces nvarchar(100)
// Bug ##2: String == comparison means length is never appended

id = createUUID();
sink = entityNew( "KitchenSink", { id: id } );
sink.setVarcharCol( "hello" );
sink.setNvarcharCol( "world" );
entitySave( sink );
ormFlush();

// verify round-trip works
entityReload( sink );
if ( sink.getVarcharCol() != "hello" ) throw( message="varchar round-trip failed: got #sink.getVarcharCol()#" );
if ( sink.getNvarcharCol() != "world" ) throw( message="nvarchar round-trip failed: got #sink.getNvarcharCol()#" );

// verify column length via JDBC metadata
result = queryExecute(
	"SELECT COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'KITCHENSINK' AND COLUMN_NAME IN ('VARCHARCOL', 'NVARCHARCOL')"
);
for ( row in result ) {
	if ( row.COLUMN_NAME == "VARCHARCOL" && row.CHARACTER_MAXIMUM_LENGTH != 50 )
		throw( message="varcharCol length should be 50, got #row.CHARACTER_MAXIMUM_LENGTH#" );
	if ( row.COLUMN_NAME == "NVARCHARCOL" && row.CHARACTER_MAXIMUM_LENGTH != 100 )
		throw( message="nvarcharCol length should be 100, got #row.CHARACTER_MAXIMUM_LENGTH#" );
}

echo( "ok" );
</cfscript>
