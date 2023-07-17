component extends="testbox.system.BaseSpec" {

	function beforeAll(){
        variables.testXMLFile = expandPath( "/tests/models/User.cfc.hbm.xml" );
	}

	public void function run(){
		describe( "hbm.xml", () => {
            describe( "format", () => {
                it( "is generated on orm startup", () => {
                    expect( fileExists( variables.testXMLFile ) ).toBeTrue();
                })
                it( "is valid, parseable XML", () => {
                    var xmlString = fileRead( variables.testXMLFile );
                    expect( isValid( "xml", xmlString ) ).tobeTrue();
                    variables.testXML = xmlParse( xmlString );
                    debug( variables.testXML );
                });
                it( "matches the expected format", () => {
                    expect( variables.testXML.xmlRoot.xmlName ).toBe( "hibernate-mapping" );
                    expect( variables.testXML.xmlRoot.xmlComment ).toInclude( "tests/models/User.cfc" )
                                                    .toInclude( "compilation-time:" );

                    expect( variables.testXML.xmlRoot.xmlChildren ).toHaveLength( 1 );
                    var classXML = variables.testXML.xmlRoot.xmlChildren.first();

                    expect( classXML.xmlAttributes )
                        .toHaveKey( "entity-name" )
                        .toHaveKey( "lazy" )
                        .toHaveKey( "node" )
                        .toHaveKey( "table" );
                    expect( classXML.xmlAttributes[ "entity-name" ] ).toBe( "User" );
                    expect( classXML.xmlAttributes[ "table" ] ).toBe( "`User`" );

                    var props = classXML.xmlChildren;
                    var expectedPropNames = [ "name", "username", "password", "createdOn" ];
                    var actualPropNames = props
                        .filter( ( prop ) => prop.xmlName == "property" )
                        .map( ( prop ) => prop.xmlAttributes.name );
                        debug( actualPropNames );
                    expectedPropNames.each( ( expectedProp ) => {
                        expect( arrayContains( actualPropNames, expectedProp ) != 0 ).toBeTrue()
                    });
                } );
            });
		} );
	}

}