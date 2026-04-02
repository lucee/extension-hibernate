<cfscript>
	// insert a row with NULL name directly via SQL
	queryExecute( "DELETE FROM LDEV4121 WHERE id='12345x'", {}, { datasource: "h2" } );
	queryExecute( "INSERT INTO LDEV4121( id, name ) VALUES( '12345x', NULL )", {}, { datasource: "h2" } );

	ormClearSession();

	theOrg = entityLoadByPK( "Org4121", "12345x" );
	if ( isNull( theOrg ) )
		throw( message="entity not found" );

	echo( theOrg.getName() );
</cfscript>
