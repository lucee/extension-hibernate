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

			// Hibernate 7.3 enforces read-only on collections (fixes the H5.6 asymmetry
			// where scalars honoured read-only but collections silently mutated).
			it( "collection add on read-only entity does not persist", function() {
				var result = _InternalRequest( template: "#uri()#/setReadOnlyCollectionAdd.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "collection remove on read-only entity does not persist", function() {
				var result = _InternalRequest( template: "#uri()#/setReadOnlyCollectionRemove.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "readOnlyEntity";
	}

}
