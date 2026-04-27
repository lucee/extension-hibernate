<cfscript>
// ormExecuteQuery( ..., params, unique=true ) — WHERE clause matches 3 rows, must throw.

try {
	result = ormExecuteQuery(
		"FROM MultiEntity WHERE status = :status",
		{ status: "active" },
		true
	);
	throw( message="executeQueryParamUniqueMulti: expected throw with 3 active rows, got result of type [#( isNull( result ) ? "null" : getMetadata( result ).getName() )#]" );
} catch ( any e ) {
	if ( e.message contains "executeQueryParamUniqueMulti:" ) rethrow;
	// expected
}
echo( "ok" );
</cfscript>
