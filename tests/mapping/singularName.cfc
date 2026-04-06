component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "singularName attribute [H2]", function() {

			it( "singularName generates addBook/hasBook/removeBook methods", function() {
				var result = _InternalRequest( template: "#uri()#/singularNameMethods.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "singularName";
	}

}
