component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "lazy proxy strategies on many-to-one [H2]", function() {

			it( "lazy=proxy loads data on property access", function() {
				var result = _InternalRequest( template: "#uri()#/lazyProxy.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "lazy=no-proxy loads data on property access", function() {
				var result = _InternalRequest( template: "#uri()#/lazyNoProxy.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "lazyProxy";
	}

}
