component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "fieldtype=collection [h2]", function() {

			describe( "array (bag) collection", function() {

				it( "round-trip: insert, load, verify values", function() {
					var result = _InternalRequest( template: "#uri()#/arrayRoundTrip.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

				it( "empty collection returns empty array, not null", function() {
					var result = _InternalRequest( template: "#uri()#/emptyCollection.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

			});

			describe( "struct (map) collection", function() {

				it( "round-trip: insert, load, verify key-value pairs", function() {
					var result = _InternalRequest( template: "#uri()#/mapRoundTrip.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

			});

			describe( "lazy attribute on collections", function() {

				it( "lazy=false on array collection eagerly loads elements", function() {
					var result = _InternalRequest( template: "#uri()#/eagerArray.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

				it( "lazy=false on struct collection eagerly loads elements", function() {
					var result = _InternalRequest( template: "#uri()#/eagerMap.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

				it( "lazy=extra on array collection works", function() {
					var result = _InternalRequest( template: "#uri()#/extraLazy.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "collections";
	}

}
