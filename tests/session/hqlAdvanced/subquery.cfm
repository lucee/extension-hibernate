<cfscript>
// HQL subquery — find authors who have books priced above average
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (1, 'Alice')" );
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (2, 'Bob')" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (1, 'Cheap', 5.00, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (2, 'Pricey', 50.00, 2)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (3, 'Mid', 20.00, 2)" );
ormClearSession();

// avg price is 25.00, so only Bob's "Pricey" (50.00) is above avg
results = ORMExecuteQuery(
	"select distinct a from HqlAuthor a join a.books b where b.price > (select avg(b2.price) from HqlBook b2)"
);
if ( arrayLen( results ) != 1 )
	throw( message="expected 1 author with above-avg book, got #arrayLen( results )#" );
if ( results[ 1 ].getName() != "Bob" )
	throw( message="expected Bob, got #results[ 1 ].getName()#" );

echo( "ok" );
</cfscript>
