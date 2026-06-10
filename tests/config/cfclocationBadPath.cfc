component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM cfclocation bad-path handling", function() {

			it( "all-bad array silently falls back to defaultCFCLocation (request template dir)", function() {
				var result = _InternalRequest( template: "#uri()#/allBadArray/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "single bad string falls back to defaultCFCLocation", function() {
				var result = _InternalRequest( template: "#uri()#/singleBadString/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "mixed good and bad paths keeps only the good entries", function() {
				var result = _InternalRequest( template: "#uri()#/mixed/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cfclocationBadPath";
	}

}
