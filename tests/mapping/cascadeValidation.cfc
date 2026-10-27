component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "cascade attribute validation", function() {

			// Valid combo exercises: a comma-separated list, the save-update bridge
			// to persist,merge, and several native H7 tokens. SF must build cleanly.
			it( "accepts comma-separated valid tokens including the save-update bridge", function() {
				var result = _InternalRequest( template: "/testAdditional/mapping/cascadeValidationValid/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			// `delete_orphan` is one of the never-worked underscore synonyms once
			// advertised by HibernateCaster.cascade. Validator must reject it pre-Hibernate
			// with the Lucee-level error listing canonical valid values.
			it( "rejects underscore synonyms with a clear error listing valid values", function() {
				expect( function() {
					_InternalRequest( template: "/testAdditional/mapping/cascadeValidationInvalid/probe.cfm" );
				}).toThrow( regex="Invalid value \[delete_orphan\] for attribute \[cascade\].*valid values are" );
			});

		});

	}

}
