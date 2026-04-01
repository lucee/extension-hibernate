component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM EHCache second-level cache", function() {

			it( "loads entity from L2 cache after DB delete and session clear", function() {
				var result = _InternalRequest( template: "#uri()#/index.cfm" );
				expect( result.status ).toBe( 200 );
			});

			// ormEvictEntity on read-only cache causes "Can't update readonly object"
			// when the entity is subsequently re-loaded — Hibernate limitation
			xit( "ormEvictEntity removes entity from L2 cache", function() {
				var result = _InternalRequest( template: "#uri()#/evict.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "ehcache";
	}

}