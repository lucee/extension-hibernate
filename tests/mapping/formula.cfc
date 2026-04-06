component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "formula attribute (computed properties) [H2]", function() {

			it( "formula computes value from DB, no column created", function() {
				var result = _InternalRequest( template: "#uri()#/formulaProperty.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "formula property is read-only — setTotal() doesn't persist", function() {
				var result = _InternalRequest( template: "#uri()#/formulaReadOnly.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "formula";
	}

}
