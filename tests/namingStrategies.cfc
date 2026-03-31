component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM naming strategies", function() {

			it( "SmartNamingStrategy converts camelCase to UPPER_UNDERSCORE", function() {
				var result = _InternalRequest(
					template: "#uri()#/smart.cfm",
					url: { strategy: "smart" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "CFCNamingStrategy invokes custom CFC for table and column names", function() {
				var result = _InternalRequest(
					template: "#uri()#/cfcStrategy.cfm",
					url: { strategy: "NamingHandler" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "namingStrategies";
	}

}
