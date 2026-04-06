component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "column attribute (custom column name) [H2]", function() {

			it( "property column maps to custom DB column name", function() {
				var result = _InternalRequest( template: "#uri()#/columnMapping.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "columnMapping";
	}

}
