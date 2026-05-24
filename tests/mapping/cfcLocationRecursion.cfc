component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM cfclocation recursion across nested Application.cfc", function() {

			// Parent's cfclocation recursion picks up sibling Application.cfc dirs
			// (current cross-engine behaviour — both Lucee and ACF; see LDEV-1697
			// tracker for Fix B rationale). Without the matching /childns mapping
			// in the parent app, Foo's cfc="childns.Bar" ref is unresolvable and
			// the SF build correctly throws with source context.
			it( "without /childns mapping in parent, unresolvable dotted cfc ref throws with context", function() {
				var template = "#uri()#/test.cfm";
				var caught = "";
				try {
					_InternalRequest( template: template );
					fail( "expected SF build to throw on unresolvable cfc=[childns.Bar]" );
				} catch ( any e ) {
					caught = e.message;
				}
				expect( caught ).toInclude( "Cannot resolve entity reference [childns.Bar]" );
				expect( caught ).toInclude( "property [bar]" );
			});

			// When the parent app declares the matching /childns mapping, the same
			// recursion-picked entities resolve correctly and entityNew works.
			it( "with /childns mapping in parent, dotted cfc ref resolves and entityNew works", function() {
				var template = "#uri()#/test.cfm";
				var result = _InternalRequest( template: template, url: { withMapping: true } );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cfcLocationRecursion";
	}

}
