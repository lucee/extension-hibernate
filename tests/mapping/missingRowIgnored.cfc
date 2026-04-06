component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "missingRowIgnored attribute [MySQL]", function() {

			it( title="missingRowIgnored=true returns null for orphaned FK", skip="#notHasMysql()#", body=function() {
				var result = _InternalRequest( template: "#uri()#/ignoredReturnsNull.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( title="missingRowIgnored=false handles orphaned FK", skip="#notHasMysql()#", body=function() {
				var result = _InternalRequest( template: "#uri()#/strictThrows.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private boolean function notHasMysql() {
		return isEmpty( server.getDatasource( "mysql" ) );
	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "missingRowIgnored";
	}

}
