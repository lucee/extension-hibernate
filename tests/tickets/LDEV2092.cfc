component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "LDEV-2092 ormEvictEntity with multiple datasources", function() {

			it( "ormEvictEntity works when entities span multiple datasources with L2 cache", function() {
				var result = _InternalRequest( template: "#uri()#/evictEntity.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormEvictCollection works on non-default datasource with L2 cache", function() {
				var result = _InternalRequest( template: "#uri()#/evictCollection.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "LDEV2092";
	}

}
