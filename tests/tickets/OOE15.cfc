component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "OOE-15 / LDEV-305: ID property without ormtype + generator=native", function() {

			it( "native generator ID works without explicit ormtype", function() {
				var result = _InternalRequest( template: "#uri()#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "OOE15";
	}

}
