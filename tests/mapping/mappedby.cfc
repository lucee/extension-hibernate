component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "mappedby attribute — one-to-one unique FK association [H2]", function() {

			// CFML ORM's mappedby is NOT JPA's mappedBy.
			// It means "the FK references this property in the target CFC".
			// Used for one-to-one unique FK associations where the non-FK side
			// needs to navigate back to the FK side.
			// See: Adobe docs "Unique Foreign Key association" section
			it( "one-to-one with mappedby resolves from both sides", function() {
				var result = _InternalRequest( template: "#uri()#/mappedbyRoundTrip.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "mappedby";
	}

}
