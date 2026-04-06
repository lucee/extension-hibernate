<cfscript>
// lazy=false fetch=select: artworks loaded immediately via separate SELECT
aid = createUUID();
artist = entityNew( "IFArtist", { id: aid, name: "Picasso" } );
entitySave( artist );
ormFlush();

queryExecute( "INSERT INTO IF_Artwork ( id, title, artistId ) VALUES ( :id, :title, :aid )",
	{ id: createUUID(), title: "Guernica", aid: aid } );
queryExecute( "INSERT INTO IF_Artwork ( id, title, artistId ) VALUES ( :id, :title, :aid )",
	{ id: createUUID(), title: "Les Demoiselles", aid: aid } );
ormClearSession();

// loading artist should immediately load artworks (lazy=false)
loaded = entityLoadByPK( "IFArtist", aid );
artworks = loaded.getArtworks();
if ( arrayLen( artworks ) != 2 )
	throw( message="expected 2 artworks immediately loaded, got #arrayLen( artworks )#" );

echo( "ok" );
</cfscript>
