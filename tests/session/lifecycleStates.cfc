component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Entity lifecycle states [H2]", function() {

			it( "transient -> persistent -> detached -> re-attached -> removed", function() {
				var result = _InternalRequest( template: "#uri()#/transitions.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "lifecycleStates";
	}

}
