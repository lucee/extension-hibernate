component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV2453" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-2453 entityToQuery() with properties that are not mapped to a column", function() {

			it( "works for an entity extending a non persistent component with properties", function() {
				local.result = _InternalRequest( template: "#uri#/test.cfm", url: { scene: "single" } );
				expect( trim( result.filecontent ) ).toBe( "id,name|1|lucee" );
			});

			it( "works for an array of entities extending a non persistent component with properties", function() {
				local.result = _InternalRequest( template: "#uri#/test.cfm", url: { scene: "array" } );
				expect( trim( result.filecontent ) ).toBe( "id,name|2|lucee,railo" );
			});

			it( "works for an entity with a persistent=false property", function() {
				local.result = _InternalRequest( template: "#uri#/test.cfm", url: { scene: "transient" } );
				expect( trim( result.filecontent ) ).toBe( "id,name|1|lucee" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
