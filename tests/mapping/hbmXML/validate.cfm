<cfscript>
// Force ORM init so mappings are generated
entitySave( entityNew( "Person", { id: createUUID(), name: "Test" } ) );
ormFlush();

// Find the generated hbm.xml
hbmFile = getDirectoryFromPath( getCurrentTemplatePath() ) & "Person.cfc.hbm.xml";
if ( !fileExists( hbmFile ) ) throw( message="hbm.xml not generated at #hbmFile#" );

// Read and parse — skip DTD validation since it references external DTD
xmlString = fileRead( hbmFile );
if ( !len( trim( xmlString ) ) ) throw( message="hbm.xml is empty" );

// Strip DTD declaration to avoid network fetch, then parse
cleanXML = reReplace( xmlString, "<!DOCTYPE[^>]*>", "", "all" );
doc = xmlParse( cleanXML );
if ( doc.xmlRoot.xmlName != "hibernate-mapping" ) throw( message="root element should be hibernate-mapping, got #doc.xmlRoot.xmlName#" );

// Should have exactly one class element
if ( arrayLen( doc.xmlRoot.xmlChildren ) != 1 ) throw( message="expected 1 class element, got #arrayLen( doc.xmlRoot.xmlChildren )#" );

classXML = doc.xmlRoot.xmlChildren[ 1 ];
if ( !structKeyExists( classXML.xmlAttributes, "entity-name" ) ) throw( message="class should have entity-name attribute" );
if ( classXML.xmlAttributes[ "entity-name" ] != "Person" ) throw( message="entity-name should be Person, got #classXML.xmlAttributes[ 'entity-name' ]#" );

// Verify expected properties exist
props = classXML.xmlChildren.filter( function( el ) { return el.xmlName == "property"; } );
propNames = props.map( function( el ) { return el.xmlAttributes.name; } );
for ( expected in [ "name", "age", "active" ] ) {
	if ( !propNames.find( expected ) ) throw( message="missing property: #expected#" );
}

echo( "ok" );
</cfscript>
