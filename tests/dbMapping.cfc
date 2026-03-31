component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "useDBForMapping", function() {

			it( "can save and load entities with useDBForMapping=true", function() {
				var result = _InternalRequest( template: "#uri()#/verify.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "dbMapping";
	}

}
