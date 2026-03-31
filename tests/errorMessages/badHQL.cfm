<cfscript>
// ormExecuteQuery with invalid HQL should throw
try {
	ormExecuteQuery( "SELECT BOGUS FROM FakeEntity" );
	throw( message="should have thrown" );
} catch ( any e ) {
	// just verify it does throw — the exact message varies by Hibernate version
	if ( e.message contains "should have thrown" )
		throw( message="bad HQL did not throw an error" );
}

echo( "ok" );
</cfscript>
