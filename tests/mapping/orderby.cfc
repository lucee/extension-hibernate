component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "orderby attribute on collections [H2]", function() {

			it( "one-to-many orderby sorts tracks by position ASC", function() {
				var result = _InternalRequest( template: "#uri()#/orderbyAsc.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "orderby";
	}

}
