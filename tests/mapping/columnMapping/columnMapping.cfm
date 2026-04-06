<cfscript>
id = createUUID();
c = entityNew( "Contact", { id: id, firstName: "Zac", lastName: "Spitzer", emailAddr: "zac@lucee.org" } );
entitySave( c );
ormFlush();

// verify via direct SQL using the actual column names
row = queryExecute( "SELECT first_name, last_name, email_address FROM CM_Contact WHERE id = :id", { id: id } );
if ( row.recordCount != 1 )
	throw( message="expected 1 row" );
if ( row.first_name != "Zac" || row.last_name != "Spitzer" || row.email_address != "zac@lucee.org" )
	throw( message="column values don't match: #row.first_name#, #row.last_name#, #row.email_address#" );

// verify column names in schema are snake_case, not camelCase
cols = queryExecute(
	"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CM_CONTACT' AND COLUMN_NAME IN ('FIRST_NAME','LAST_NAME','EMAIL_ADDRESS')"
);
if ( cols.recordCount != 3 )
	throw( message="expected 3 custom-named columns, got #cols.recordCount#" );

ormClearSession();
loaded = entityLoadByPK( "Contact", id );
if ( loaded.getFirstName() != "Zac" )
	throw( message="expected Zac, got #loaded.getFirstName()#" );

echo( "ok" );
</cfscript>
