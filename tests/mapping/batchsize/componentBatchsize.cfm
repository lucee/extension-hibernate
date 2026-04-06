<cfscript>
// Component-level batchsize affects many-to-one proxy resolution.
// When multiple Books reference different Publishers, accessing one Publisher
// proxy should batch-load other Publisher proxies in the same session.
// We can't easily count queries without logSQL, but we verify:
// 1. The batchsize attribute is accepted without error
// 2. Many-to-one proxies resolve correctly across multiple entities

// create 6 publishers
pids = [];
for ( i = 1; i <= 6; i++ ) {
	pid = createUUID();
	arrayAppend( pids, pid );
	entitySave( entityNew( "Publisher", { id: pid, name: "Pub #i#" } ) );
}
ormFlush();

// create 2 books per publisher (12 books total)
for ( pid in pids ) {
	for ( j = 1; j <= 2; j++ ) {
		book = entityNew( "Book", { id: createUUID(), title: "Book #j# by #pid#" } );
		book.setPublisher( entityLoadByPK( "Publisher", pid ) );
		entitySave( book );
	}
}
ormFlush();
ormClearSession();

// load all books — each book's publisher is a lazy many-to-one proxy
books = entityLoad( "Book" );
if ( arrayLen( books ) != 12 )
	throw( message="expected 12 books, got #arrayLen( books )#" );

// access publisher on each book — with batchsize=5 on Publisher component,
// Hibernate should batch-resolve publisher proxies
publisherNames = {};
for ( book in books ) {
	pub = book.getPublisher();
	publisherNames[ pub.getName() ] = true;
}

if ( structCount( publisherNames ) != 6 )
	throw( message="expected 6 distinct publishers, got #structCount( publisherNames )#" );

echo( "ok" );
</cfscript>
