component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		// Hibernate 7.3+ HQL identifiers are strictly case-sensitive — they must match
		// the case declared in the CFC. Locks down the documented breaking change
		// (see BREAKING-CHANGES.md "HQL identifiers are case-sensitive").
		describe( "HQL case-sensitivity (Hibernate 7.3+ strict)", function() {

			it( "exact-case alias chain resolves", function() {
				var result = _InternalRequest( template: "#uri()#/aliasMixed.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "wrong-case property in WHERE throws path-expression error", function() {
				var result = _InternalRequest( template: "#uri()#/whereLowercase.cfm" );
				expect( trim( result.filecontent ) ).toInclude( "Could not interpret path expression" );
			});

			it( "wrong-case entity name in FROM throws root-entity error", function() {
				// H7 distinguishes property-path errors ("Could not interpret path expression")
				// from root-entity errors ("Could not resolve root entity")
				var result = _InternalRequest( template: "#uri()#/entityLowercase.cfm" );
				expect( trim( result.filecontent ) ).toInclude( "Could not resolve root entity" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "hqlCaseSensitive";
	}

}
