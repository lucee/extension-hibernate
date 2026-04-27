<cfscript>
// Control: filter narrows to exactly one row — unique=true returns the entity.
// Confirms our test fixture setup, and that single-row + unique=true still works.

result = ormExecuteQuery(
	"FROM MultiEntity WHERE status = :status",
	{ status: "inactive" },
	true
);

if ( isNull( result ) )
	throw( message="executeQuerySingleMatch: expected entity, got null" );
if ( !isObject( result ) )
	throw( message="executeQuerySingleMatch: expected object, got [#getMetadata( result ).getName()#]" );
if ( result.getName() != "delta" )
	throw( message="executeQuerySingleMatch: expected delta, got [#result.getName()#]" );

echo( "ok" );
</cfscript>
