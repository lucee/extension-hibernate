component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "where filter attribute [H2]", function() {

			it( "component-level where filters entityLoad results", function() {
				var result = _InternalRequest( template: "#uri()#/componentWhere.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "relationship-level where filters one-to-many collection", function() {
				var result = _InternalRequest( template: "#uri()#/relationshipWhere.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "whereFilter";
	}

}
