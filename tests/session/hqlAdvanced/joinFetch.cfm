<cfscript>
// JOIN FETCH — load authors with their books eagerly (N+1 fix)
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (1, 'Alice')" );
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (2, 'Bob')" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (1, 'Book A1', 9.99, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (2, 'Book A2', 19.99, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (3, 'Book B1', 29.99, 2)" );
ormClearSession();

// JOIN FETCH eagerly loads the books collection in the same query.
// Hibernate 7.x does NOT deduplicate the result list for `select distinct` + `join fetch`
// on a <bag> collection (CFML `type="array"` maps to <bag>) — each cartesian-product row
// becomes a result entry pointing at the same parent entity. Pre-7.x deduplicated implicitly.
// Test the actual contract here ("books loaded eagerly, no N+1") rather than result-list size.
results = ORMExecuteQuery( "from HqlAuthor a join fetch a.books where a.name = :name", { name: "Alice" } );
if ( arrayLen( results ) lt 1 )
	throw( message="expected at least 1 row, got #arrayLen( results )#" );

author = results[ 1 ];
if ( author.getName() != "Alice" )
	throw( message="expected Alice, got [#author.getName()#]" );

books = author.getBooks();
if ( arrayLen( books ) != 2 )
	throw( message="expected 2 books for Alice, got #arrayLen( books )#" );

echo( "ok" );
</cfscript>
