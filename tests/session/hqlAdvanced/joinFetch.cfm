<cfscript>
// JOIN FETCH — load authors with their books in a single query (N+1 fix)
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (1, 'Alice')" );
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (2, 'Bob')" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (1, 'Book A1', 9.99, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (2, 'Book A2', 19.99, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (3, 'Book B1', 29.99, 2)" );
ormClearSession();

// JOIN FETCH eagerly loads the books collection in the same query
results = ORMExecuteQuery( "select distinct a from HqlAuthor a join fetch a.books where a.name = :name", { name: "Alice" } );
if ( arrayLen( results ) != 1 )
	throw( message="expected 1 author, got #arrayLen( results )#" );

// books should be loaded via the join — verifying correct data, not query count
books = results[ 1 ].getBooks();
if ( arrayLen( books ) != 2 )
	throw( message="expected 2 books for Alice, got #arrayLen( books )#" );

echo( "ok" );
</cfscript>
