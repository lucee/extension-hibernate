component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "foreignkey attribute [H2]", function() {

			it( "foreignkey attribute creates FK constraint on relationship", function() {
				var result = _InternalRequest( template: "#uri()#/foreignKeyName.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "foreignKeyName";
	}

}
