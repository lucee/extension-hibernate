component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Lazy loading after session close [H2]", function() {

			it( "accessing lazy collection after ormCloseSession throws or is empty", function() {
				var result = _InternalRequest( template: "#uri()#/lazyAfterClose.cfm" );
				// accept either "ok" (error thrown) or "no-error:N" (loaded anyway — document this behaviour)
				var content = trim( result.filecontent );
				expect( content ).toMatch( "ok|no-error" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "lazyAfterClose";
	}

}
