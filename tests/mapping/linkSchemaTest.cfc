component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "linkschema attribute [MySQL]", function() {

			it( title="many-to-many with linkschema puts join table in separate schema", skip="#notHasMysql()#", body=function() {
				var result = _InternalRequest( template: "#uri()#/linkSchema.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private boolean function notHasMysql() {
		return isEmpty( server.getDatasource( "mysql" ) );
	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "linkSchemaTest";
	}

}
