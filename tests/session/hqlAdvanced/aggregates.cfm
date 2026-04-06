<cfscript>
// HQL aggregate functions: count, sum, avg, min, max
queryExecute( "INSERT INTO HqlAuthor (id, name) VALUES (1, 'Alice')" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (1, 'Cheap', 5.00, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (2, 'Medium', 15.00, 1)" );
queryExecute( "INSERT INTO HqlBook (id, title, price, authorId) VALUES (3, 'Expensive', 30.00, 1)" );
ormClearSession();

// count
cnt = ORMExecuteQuery( "select count(b) from HqlBook b", {}, true );
if ( cnt != 3 ) throw( message="count: expected 3, got #cnt#" );

// sum
total = ORMExecuteQuery( "select sum(b.price) from HqlBook b", {}, true );
if ( abs( total - 50.00 ) > 0.01 ) throw( message="sum: expected 50.00, got #total#" );

// avg
avg = ORMExecuteQuery( "select avg(b.price) from HqlBook b", {}, true );
if ( abs( avg - 16.67 ) > 0.01 ) throw( message="avg: expected ~16.67, got #avg#" );

// min / max
minPrice = ORMExecuteQuery( "select min(b.price) from HqlBook b", {}, true );
maxPrice = ORMExecuteQuery( "select max(b.price) from HqlBook b", {}, true );
if ( abs( minPrice - 5.00 ) > 0.01 ) throw( message="min: expected 5.00, got #minPrice#" );
if ( abs( maxPrice - 30.00 ) > 0.01 ) throw( message="max: expected 30.00, got #maxPrice#" );

echo( "ok" );
</cfscript>
