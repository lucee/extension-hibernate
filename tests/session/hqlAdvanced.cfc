component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Advanced HQL [H2]", function() {

			it( "JOIN FETCH eagerly loads collection in single query", function() {
				var result = _InternalRequest( template: "#uri()#/joinFetch.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "aggregate functions: count, sum, avg, min, max", function() {
				var result = _InternalRequest( template: "#uri()#/aggregates.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "subquery: find entities matching aggregate condition", function() {
				var result = _InternalRequest( template: "#uri()#/subquery.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "HQL ORDER BY DESC returns reverse order", function() {
				var result = _InternalRequest( template: "#uri()#/orderByDesc.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "hqlAdvanced";
	}

}
