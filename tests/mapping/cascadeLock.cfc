component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "cascade='lock' on a one-to-many", function() {

			it( "lock cascade is accepted at SF build", function() {
				var result = _InternalRequest( template: "#uri()#/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cascadeLock";
	}

}
