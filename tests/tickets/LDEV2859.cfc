component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV2859" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-2859 entityToQuery() with the name of the entity itself", function() {

			it( "works with an array of entities", function() {
				local.result = _InternalRequest( template: "#uri#/test.cfm", url: { scene: "array" } );
				expect( trim( result.filecontent ) ).toBe( "2:lucee,railo" );
			});

			it( "works with a single entity", function() {
				local.result = _InternalRequest( template: "#uri#/test.cfm", url: { scene: "single" } );
				expect( trim( result.filecontent ) ).toBe( "1:lucee" );
			});

			it( "the name is case insensitive", function() {
				local.result = _InternalRequest( template: "#uri#/test.cfm", url: { scene: "case" } );
				expect( trim( result.filecontent ) ).toBe( "2:lucee,railo" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
