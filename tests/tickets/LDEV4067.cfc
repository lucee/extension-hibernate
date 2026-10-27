component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV4067" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-4067 closures/lambdas in ORM entities get wrong scope", function() {

			it( "lambda in nested struct can access entity properties", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "Michael" );
			});

			it( "closure assigned as direct data member can access entity properties", function() {
				var result = _InternalRequest( template: "#uri#/test_direct.cfm" );
				expect( trim( result.filecontent ) ).toBe( "Michael" );
			});

			it( "lambda on a new entity (not loaded) can access entity properties", function() {
				var result = _InternalRequest( template: "#uri#/test_new.cfm" );
				expect( trim( result.filecontent ) ).toBe( "Michael" );
			});

			it( "each entity instance gets its own lambda and memento struct", function() {
				var result = deserializeJSON( _InternalRequest( template: "#uri#/test_isolation.cfm" ).filecontent );
				expect( result.newA ).toBe( "Alice" );
				expect( result.newB ).toBe( "Bob" );
				expect( result.loadedA ).toBe( "Alice" );
				expect( result.loadedB ).toBe( "Bob" );
				expect( result.mementoShared ).toBeFalse();
				expect( result.markerOnB ).toBeFalse();
			});

			it( "init() and property defaults still apply to new and loaded entities", function() {
				var result = deserializeJSON( _InternalRequest( template: "#uri#/test_init.cfm" ).filecontent );
				expect( result.newInitCalled ).toBeTrue();
				expect( result.newStatus ).toBe( "active" );
				expect( result.loadedInitCalled ).toBeTrue();
				expect( result.loadedStatus ).toBe( "archived" );
				expect( result.loadedName ).toBe( "Michael" );
				expect( result.loadedClosure ).toBe( "Michael" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
