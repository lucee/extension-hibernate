component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "precision / scale attributes [H2]", function() {

			it( "big_decimal with precision=12, scale=4 round-trips correctly", function() {
				var result = _InternalRequest( template: "#uri()#/precisionScale.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "numericPrecision";
	}

}
