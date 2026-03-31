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

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "relationships";
	}

}
