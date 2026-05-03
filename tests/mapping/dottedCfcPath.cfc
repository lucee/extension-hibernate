component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM dotted cfc path resolution", function() {

			it( "resolves property cfc='dotted.Garage' via /dotted Application mapping", function() {
				var result = _InternalRequest( template: "#uri()#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "dottedCfcPath";
	}

}
