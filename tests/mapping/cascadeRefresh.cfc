component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "cascade='refresh' on a one-to-many", function() {

			it( "refresh cascade is accepted at SF build", function() {
				var result = _InternalRequest( template: "#uri()#/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cascadeRefresh";
	}

}
