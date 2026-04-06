<cfscript>
// HQL ORDER BY DESC
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (1, 'Alice')" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (1, 'Cheap', 5.00, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (2, 'Medium', 15.00, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (3, 'Expensive', 30.00, 1)" );
ormClearSession();

results = ORMExecuteQuery( "from HqlBook b order by b.price desc" );
if ( arrayLen( results ) != 3 )
	throw( message="expected 3 books, got #arrayLen( results )#" );
if ( results[ 1 ].getTitle() != "Expensive" )
	throw( message="first should be Expensive, got #results[ 1 ].getTitle()#" );
if ( results[ 3 ].getTitle() != "Cheap" )
	throw( message="last should be Cheap, got #results[ 3 ].getTitle()#" );

echo( "ok" );
</cfscript>
