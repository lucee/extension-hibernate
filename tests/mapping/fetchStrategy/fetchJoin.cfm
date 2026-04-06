<cfscript>
aid = createUUID();
author = entityNew( "Author", { id: aid, name: "Jane" } );
entitySave( author );
entitySave( entityNew( "Article", { id: createUUID(), title: "Article 1", author: author } ) );
entitySave( entityNew( "Article", { id: createUUID(), title: "Article 2", author: author } ) );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Author", aid );
articles = loaded.getArticles();
if ( arrayLen( articles ) != 2 )
	throw( message="expected 2 articles, got #arrayLen( articles )#" );

echo( "ok" );
</cfscript>
