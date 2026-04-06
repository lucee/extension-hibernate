<cfscript>
lid = createUUID();
lib = entityNew( "Library", { id: lid, name: "City Library" } );
entitySave( lib );

book = entityNew( "LibBook", { id: createUUID(), title: "ORM for Dummies" } );

// addBook should work (generated from singularName="book")
lib.addBook( book );
entitySave( lib );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Library", lid );
if ( arrayLen( loaded.getBooks() ) != 1 )
	throw( message="expected 1 book after addBook, got #arrayLen( loaded.getBooks() )#" );

// hasBook should work
if ( !loaded.hasBook( loaded.getBooks()[ 1 ] ) )
	throw( message="hasBook should return true" );

// removeBook
loaded.removeBook( loaded.getBooks()[ 1 ] );
ormFlush();
ormClearSession();

reloaded = entityLoadByPK( "Library", lid );
if ( arrayLen( reloaded.getBooks() ) != 0 )
	throw( message="expected 0 books after removeBook, got #arrayLen( reloaded.getBooks() )#" );

echo( "ok" );
</cfscript>
