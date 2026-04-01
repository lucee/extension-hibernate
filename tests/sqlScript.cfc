component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM sqlScript setting", function() {

			it( "executes SQL seed script after schema creation", function() {
				var result = _InternalRequest( template: "#uri()#/index.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "sqlScript";
	}

}
