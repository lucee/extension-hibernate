component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Cache configuration [H2 + ehcache]", function() {

			it( "L2 cache enabled — entity survives DB delete", function() {
				var result = _InternalRequest( template: "#uri()#/l2CacheEnabled.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "cacheable HQL query stores results", function() {
				var result = _InternalRequest( template: "#uri()#/queryCacheable.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormEvictQueries clears query cache", function() {
				var result = _InternalRequest( template: "#uri()#/evictQueries.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cacheConfig";
	}

}
