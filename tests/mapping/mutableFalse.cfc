component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "mutable='false' on entity class", function() {

			it( "SF builds and entity round-trips through insert + load", function() {
				var result = _InternalRequest( template: "#uri()#/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "mutableFalse";
	}

}
