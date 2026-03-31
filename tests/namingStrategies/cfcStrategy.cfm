<cfscript>
// CFCNamingStrategy uses NamingHandler.cfc to prefix table/column names
// "UserAccount" → "tbl_useraccount", "firstName" → "col_firstname"
user = entityNew( "UserAccount", { id: createUUID(), firstName: "Zac", lastName: "Spitzer" } );
entitySave( user );
ormFlush();

// verify custom naming: table=tbl_useraccount, columns=col_firstname, col_lastname
result = queryExecute( "SELECT col_firstname, col_lastname FROM tbl_useraccount WHERE col_firstname = :fn",
	{ fn: "Zac" } );
if ( result.recordCount != 1 )
	throw( message="cfcStrategy: expected 1 row, got #result.recordCount#" );
if ( result.col_lastname[ 1 ] != "Spitzer" )
	throw( message="cfcStrategy: expected Spitzer, got #result.col_lastname[ 1 ]#" );

echo( "ok" );
</cfscript>
