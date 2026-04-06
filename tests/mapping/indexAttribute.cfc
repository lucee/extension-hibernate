component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "index attribute [H2]", function() {

			it( "index attribute creates database index on column", function() {
				var result = _InternalRequest( template: "#uri()#/indexCreated.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "indexAttribute";
	}

}
