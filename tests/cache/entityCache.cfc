component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "cacheuse / cacheName on relationships [H2]", function() {

			it( "relationship with cacheuse=read-only loads items correctly", function() {
				var result = _InternalRequest( template: "#uri()#/relationshipCache.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "entityCache";
	}

}
