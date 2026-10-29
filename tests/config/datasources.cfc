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

			it( "lazy session opening — second datasource session created on demand", function() {
				var result = _InternalRequest( template: "#uri()#/lazySession.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORMFlush() accepts a comma separated list of datasources", function() {
				var result = _InternalRequest( template: "#uri()#/flushList.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORMFlush() ignores spaces around the datasource names in a list", function() {
				var result = _InternalRequest( template: "#uri()#/flushListSpaces.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORMFlush() accepts an array of datasources", function() {
				var result = _InternalRequest( template: "#uri()#/flushArray.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORMFlush() with a single datasource or no argument flushes only that datasource", function() {
				var result = _InternalRequest( template: "#uri()#/flushSingle.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORMFlush() with an unknown datasource in the list throws before flushing anything", function() {
				var result = _InternalRequest( template: "#uri()#/flushUnknown.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( title: "ORMFlushAll() flushes all datasource sessions", skip: !hasORMFlushAll(), body: function() {
				var result = _InternalRequest( template: "#uri()#/flushAll.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private boolean function hasORMFlushAll() {
		try {
			getFunctionData( "ormflushall" );
			return true;
		} catch( any e ) {
			return false;
		}
	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "datasources";
	}

}