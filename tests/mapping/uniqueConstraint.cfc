component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "unique attribute [H2]", function() {

			it( "unique=true enforces unique constraint on column", function() {
				var result = _InternalRequest( template: "#uri()#/uniqueConstraint.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "uniqueConstraint";
	}

}
