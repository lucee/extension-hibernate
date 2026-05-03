component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM cfclocation recursion across nested Application.cfc", function() {

			// Locks in current cross-engine behaviour: cfclocation recursion is
			// blind to nested Application.cfc files. The parent app's recursive
			// scan walks into ./child/entities/ and registers Foo in the parent
			// SessionFactory, even though child/Application.cfc declares its own
			// app.
			//
			// Both Lucee and ACF behave this way. If this test ever starts
			// failing because Foo is unreachable from the parent SF, the
			// recursion strategy has changed — a behavioural break shared apps
			// may rely on. Re-evaluate before "fixing".
			it( "parent cfclocation recurses into child Application.cfc dirs", function() {
				var template = "#uri()#/test.cfm";
				var result = _InternalRequest( template: template );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cfcLocationRecursion";
	}

}
