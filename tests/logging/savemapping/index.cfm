<cfscript>
// ORM init + savemapping happens on app start — just verify the files
dir = getDirectoryFromPath( getCurrentTemplatePath() );
hbmFile = dir & "MappedEntity.cfc.hbm.xml";

if ( !fileExists( hbmFile ) )
	throw( message="Expected mapping file not found [#hbmFile#]" );

content = fileRead( hbmFile );

if ( content does not contain "MappedEntity" )
	throw( message="Mapping file does not contain entity name" );

if ( content does not contain "title" )
	throw( message="Mapping file does not contain property [title]" );

if ( content does not contain "price" )
	throw( message="Mapping file does not contain property [price]" );

echo( "ok" );
</cfscript>
