component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV4121" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-4121 property defaults should override DB NULLs", function() {

			it( "entityLoadByPK returns default value for NULL column", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "default organization name" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
