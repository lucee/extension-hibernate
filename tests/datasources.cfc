component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM multiple datasources", function() {

			it( "saves entities to their respective datasources", function() {
				var result = _InternalRequest( template: "#uri()#/index.cfm" );
				expect( result.status ).toBe( 200 );
			});

			it( "entities are isolated to their configured datasource", function() {
				var result = _InternalRequest( template: "#uri()#/isolation.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "HQL queries work across different datasources", function() {
				var result = _InternalRequest( template: "#uri()#/hqlScoped.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORMFlushAll() flushes all datasource sessions", function() {
				var result = _InternalRequest( template: "#uri()#/flushAll.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "datasources";
	}

}