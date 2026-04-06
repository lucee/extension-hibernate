<cfscript>
aid = createUUID();
artId = createUUID();
author = entityNew( "Author", { id: aid, name: "Bob" } );
entitySave( author );
entitySave( entityNew( "Article", { id: artId, title: "My Post", author: author } ) );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Article", artId );
if ( loaded.getAuthor().getName() != "Bob" )
	throw( message="expected Bob, got #loaded.getAuthor().getName()#" );

echo( "ok" );
</cfscript>
