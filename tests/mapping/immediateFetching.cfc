component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Immediate fetching: lazy=false fetch=select [H2]", function() {

			it( "artworks loaded immediately via separate SELECT", function() {
				var result = _InternalRequest( template: "#uri()#/immediateFetch.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "immediateFetching";
	}

}
