component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ormExecuteQuery unique=true with multiple rows [H2] — locks down 5.6 baseline for 7.3 dedup change", function() {

			it( "throws when no filter and >1 row", function() {
				var result = _InternalRequest( template: "#uri()#/executeQueryUniqueMulti.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "throws when WHERE matches multiple rows", function() {
				var result = _InternalRequest( template: "#uri()#/executeQueryParamUniqueMulti.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "returns single entity when WHERE matches exactly one row", function() {
				var result = _InternalRequest( template: "#uri()#/executeQuerySingleMatch.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "uniqueResultMulti";
	}

}
