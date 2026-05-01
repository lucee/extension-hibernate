component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM relationships", function() {

			it( "many-to-one: entity references parent", function() {
				var result = _InternalRequest( template: "#uri()#/manyToOne.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "one-to-many: parent loads child collection", function() {
				var result = _InternalRequest( template: "#uri()#/oneToMany.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormEvictCollection: evicts collection from cache without error", function() {
				var result = _InternalRequest( template: "#uri()#/evictCollection.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "lazy loading: many-to-one and one-to-many load on access", function() {
				var result = _InternalRequest( template: "#uri()#/lazyLoad.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "cascade delete-orphan: deleting parent removes children", function() {
				var result = _InternalRequest( template: "#uri()#/cascadeDelete.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "LDEV-1992: entityMerge after ormClearSession with lazy relationships", function() {
				var result = _InternalRequest( template: "#uri()#/mergeAfterClear.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "many-to-many: lazy loading with linktable", function() {
				var result = _InternalRequest( template: "#uri()#/manyToMany.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "one-to-many flush: no ConcurrentModificationException with multiple children", function() {
				var result = _InternalRequest( template: "#uri()#/oneToManyFlush.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			// disabled — see LDEV-1697 (related): the parent relationships/Application.cfc has
			// cfclocation: [ relationships/ ] which recurses into dottedCfcPath/entities/ and
			// pulls Vehicle/Garage into the parent context, where /dotted isn't mapped.
			// Breaks every other test in this bundle. Local pass is SF-cache fluke; CI fails
			// every matrix cell. Re-enable when EntityFinder honours Application.cfc boundaries.
			xit( "many-to-one with dotted cfc path resolves via Application mapping", function() {
				var result = _InternalRequest( template: "#uri()#/dottedCfcPath/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "relationships";
	}

}
