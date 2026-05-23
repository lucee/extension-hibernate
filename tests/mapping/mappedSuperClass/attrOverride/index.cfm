<cfscript>
// Child redeclared `title` with column="customer_title" and length=200.
// Parent's was column="default_title" length=50. Child's wins.

// Verify the schema honoured the override: column must be `customer_title`, not `default_title`.
import org.hibernate.Session;

ormFlush();

// Probe the H2 schema. column names are uppercased by default.
schema = queryExecute(
	"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'MSUPER_CUSTOMER' ORDER BY COLUMN_NAME"
);
cols = [];
for ( row in schema ) {
	cols.append( lCase( row.COLUMN_NAME ) );
}
if ( !cols.find( "customer_title" ) )
	throw( message="schema missing override column [customer_title], got #serializeJSON( cols )#" );
if ( cols.find( "default_title" ) )
	throw( message="schema still has parent's column [default_title] — override didn't take" );

// Round-trip a value longer than the parent's 50-char limit (proves length override too).
longTitle = repeatString( "mango ", 20 );  // 120 chars
c = entityNew( "Customer" );
c.setId( createUUID() );
c.setTitle( longTitle );
entitySave( c );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Customer", c.getId() );
if ( isNull( loaded ) )
	throw( message="Customer not loaded after save" );
if ( loaded.getTitle() != longTitle )
	throw( message="title round-trip mismatch — expected [#longTitle#], got [#loaded.getTitle()#]" );

echo( "ok" );
</cfscript>
