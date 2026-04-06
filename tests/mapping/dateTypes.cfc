component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Date/Time type round-trip [H2]", function() {

			it( "date now() round-trip", function() {
				var result = _InternalRequest( template: "#uri()#/dateNow.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "specific date year/month/day", function() {
				var result = _InternalRequest( template: "#uri()#/dateSpecific.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "time round-trip hour/minute", function() {
				var result = _InternalRequest( template: "#uri()#/timeRoundTrip.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "timestamp full precision", function() {
				var result = _InternalRequest( template: "#uri()#/timestampPrecision.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "null date round-trip", function() {
				var result = _InternalRequest( template: "#uri()#/nullDate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "dateCompare with loaded date", function() {
				var result = _InternalRequest( template: "#uri()#/dateCompare.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "loaded date as HQL query parameter", function() {
				var result = _InternalRequest( template: "#uri()#/dateAsQueryParam.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "dateTypes";
	}

}
