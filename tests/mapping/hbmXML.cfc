component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "hbm.xml mapping generation", function() {

			it( "generates valid XML with correct entity structure", function() {
				var result = _InternalRequest( template: "#uri()#/validate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "hbmXML";
	}

}
