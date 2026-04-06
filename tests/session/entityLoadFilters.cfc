component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "entityLoad with struct filters / sort / options [H2]", function() {

			it( "basic struct filter", function() {
				var result = _InternalRequest( template: "#uri()#/basicFilter.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "multiple struct filters", function() {
				var result = _InternalRequest( template: "#uri()#/multipleFilters.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "null filter value (isNull path)", function() {
				var result = _InternalRequest( template: "#uri()#/nullFilter.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "sort ascending", function() {
				var result = _InternalRequest( template: "#uri()#/sortAsc.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "sort descending", function() {
				var result = _InternalRequest( template: "#uri()#/sortDesc.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "multi-column sort", function() {
				var result = _InternalRequest( template: "#uri()#/sortMultiColumn.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "filter + sort combined", function() {
				var result = _InternalRequest( template: "#uri()#/filterAndSort.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "maxresults pagination", function() {
				var result = _InternalRequest( template: "#uri()#/maxResults.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "offset + maxresults pagination", function() {
				var result = _InternalRequest( template: "#uri()#/offsetAndMax.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "cacheable option", function() {
				var result = _InternalRequest( template: "#uri()#/cacheable.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "timeout option", function() {
				var result = _InternalRequest( template: "#uri()#/timeout.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "all options combined", function() {
				var result = _InternalRequest( template: "#uri()#/allOptions.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "unique=true with no filter throws on multiple rows", function() {
				var result = _InternalRequest( template: "#uri()#/uniqueNoFilter.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "entityLoadFilters";
	}

}
