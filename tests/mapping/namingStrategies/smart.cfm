<cfscript>
// SmartNamingStrategy converts camelCase to UPPER_UNDERSCORE
// "UserAccount" → "USER_ACCOUNT", "firstName" → "FIRST_NAME"
user = entityNew( "UserAccount", { id: createUUID(), firstName: "Zac", lastName: "Spitzer" } );
entitySave( user );
ormFlush();

// verify table name is USER_ACCOUNT and columns are FIRST_NAME, LAST_NAME
result = queryExecute( "SELECT FIRST_NAME, LAST_NAME FROM USER_ACCOUNT WHERE FIRST_NAME = :fn",
	{ fn: "Zac" } );
if ( result.recordCount != 1 )
	throw( message="smart: expected 1 row, got #result.recordCount#" );
if ( result.LAST_NAME[ 1 ] != "Spitzer" )
	throw( message="smart: expected Spitzer, got #result.LAST_NAME[ 1 ]#" );

echo( "ok" );
</cfscript>
