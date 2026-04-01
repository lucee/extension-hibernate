<cfscript>
// sqlScript should have seeded two rows after dropcreate
result = queryExecute( "SELECT count(*) as cnt FROM Item" );
if ( result.cnt[ 1 ] < 2 )
	throw( message="sqlScript: expected at least 2 seeded rows, got #result.cnt[ 1 ]#" );

// verify specific seeded data
seeded = entityLoadByPK( "Item", "seed-1" );
if ( isNull( seeded ) )
	throw( message="sqlScript: seed-1 not found" );
if ( seeded.getName() != "Seeded Widget" )
	throw( message="sqlScript: expected 'Seeded Widget', got '#seeded.getName()#'" );

echo( "ok" );
</cfscript>
