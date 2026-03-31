component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM cfclocation support", function() {

			it( "discovers entities across multiple cfclocation directories", function() {
				var result = _InternalRequest( template: "#uri()#/multipleDirectories.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cfclocation";
	}

}
