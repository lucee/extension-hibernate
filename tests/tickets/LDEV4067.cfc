component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV4067" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-4067 closures/lambdas in ORM entities get wrong scope", function() {

			it( "lambda in nested struct can access entity properties", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "Michael" );
			});

			it( "closure assigned as direct data member can access entity properties", function() {
				var result = _InternalRequest( template: "#uri#/test_direct.cfm" );
				expect( trim( result.filecontent ) ).toBe( "Michael" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
