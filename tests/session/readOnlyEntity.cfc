component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Read-only entity behaviour [H2] — locks down 5.6 baseline for 7.3 migration", function() {

			it( "session.setReadOnly() and session.isReadOnly() round-trip", function() {
				var result = _InternalRequest( template: "#uri()#/isReadOnlyFlag.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "scalar mutation on read-only entity does not persist", function() {
				var result = _InternalRequest( template: "#uri()#/setReadOnlyScalar.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			// xit until Hibernate 7.3 — 5.6 silently lets read-only collections mutate
			// (the asymmetry 7.3 fixes: scalars honour read-only, collections don't)
			xit( "collection add on read-only entity does not persist", function() {
				var result = _InternalRequest( template: "#uri()#/setReadOnlyCollectionAdd.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			xit( "collection remove on read-only entity does not persist", function() {
				var result = _InternalRequest( template: "#uri()#/setReadOnlyCollectionRemove.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "readOnlyEntity";
	}

}
