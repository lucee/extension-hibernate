component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV6390" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-6390 ClassLoaderService cache must not break Criteria/Projection loads", function() {

			it( "should load org.hibernate.criterion.* and SQL type descriptors via createObject", function() {
				local.result = _InternalRequest( template: "#uri#/loadCriterion.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "probe: bundle CL vs TCCL identity and live ClassLoaderService instance", function() {
				local.result = _InternalRequest( template: "#uri#/classloaderProbe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "should run a Criteria with rowCount AggregateProjection", function() {
				local.result = _InternalRequest( template: "#uri#/rowCount.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
