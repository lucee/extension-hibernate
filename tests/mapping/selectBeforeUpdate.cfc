component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "selectbeforeupdate attribute [H2]", function() {

			it( "entity with selectbeforeupdate=true round-trips correctly", function() {
				var result = _InternalRequest( template: "#uri()#/selectBeforeUpdate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "selectBeforeUpdate";
	}

}
