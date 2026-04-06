component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "one-to-one relationship [H2]", function() {

			it( "one-to-one with shared PK round-trips correctly", function() {
				var result = _InternalRequest( template: "#uri()#/oneToOneRoundTrip.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "one-to-one with constrained=true enforces FK and loads", function() {
				var result = _InternalRequest( template: "#uri()#/oneToOneConstrained.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "oneToOne";
	}

}
