component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM schema modes", function() {

			it( "dropcreate creates schema and allows CRUD", function() {
				var result = _InternalRequest( template: "#uri()#/dropcreate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "schemaMode";
	}

}
