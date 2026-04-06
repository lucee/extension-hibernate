<cfscript>
// Insert 3 publishers with 5 books each, verify batchsize doesn't break loading
for ( i = 1; i <= 3; i++ ) {
	pid = createUUID();
	pub = entityNew( "Publisher", { id: pid, name: "Publisher #i#" } );
	entitySave( pub );
	for ( j = 1; j <= 5; j++ ) {
		book = entityNew( "Book", { id: createUUID(), title: "Book #i#-#j#", publisher: pub } );
		entitySave( book );
	}
}
ormFlush();
ormClearSession();

// Load all publishers and access books
publishers = entityLoad( "Publisher" );
if ( arrayLen( publishers ) != 3 )
	throw( message="expected 3 publishers, got #arrayLen( publishers )#" );

totalBooks = 0;
for ( pub in publishers ) {
	totalBooks += arrayLen( pub.getBooks() );
}
if ( totalBooks != 15 )
	throw( message="expected 15 total books, got #totalBooks#" );

echo( "ok" );
</cfscript>
