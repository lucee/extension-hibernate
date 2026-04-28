component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "cascade list with save-update + delete-orphan", function() {

			it( "list form is accepted and save-update cascade fires", function() {
				var result = _InternalRequest( template: "#uri()#/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cascadeSaveUpdateList";
	}

}
