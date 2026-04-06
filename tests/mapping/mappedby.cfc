component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "mappedby attribute [H2]", function() {

			// BUG: mappedby="team" throws "property [team] not found on entity [Team]"
			// Hibernate looks for the property on the wrong entity (parent instead of child).
			// Needs investigation — may be a HBMCreator bug or a CFML ORM limitation.
			// TODO: verify ACF behaviour with mappedby
			xit( "one-to-many with mappedby loads children without fkcolumn on parent side", function() {
				var result = _InternalRequest( template: "#uri()#/mappedbyRoundTrip.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "mappedby";
	}

}
