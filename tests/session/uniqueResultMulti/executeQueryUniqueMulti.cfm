<cfscript>
// ormExecuteQuery( ..., unique=true ) with >1 row must throw.
// Hibernate 6/7.2 had inconsistent dedup behaviour; 7.3 always throws.

try {
	result = ormExecuteQuery( "FROM MultiEntity", {}, true );
	throw( message="executeQueryUniqueMulti: expected throw with 4 rows, got result of type [#( isNull( result ) ? "null" : getMetadata( result ).getName() )#]" );
} catch ( any e ) {
	if ( e.message contains "executeQueryUniqueMulti:" ) rethrow;
	// expected — non-unique result must throw
}
echo( "ok" );
</cfscript>
