component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV4285" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-4285 entityLoad() with named arguments", function() {

			it( "positional: entityLoad(name)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 1 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "positional: entityLoad(name, idOrFilter)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 2 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "positional: entityLoad(name, idOrFilter, uniqueOrOrder)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 3 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "positional: entityLoad(name, idOrFilter, uniqueOrOrder, options)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 4 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "named: entityLoad(name, id, unique, options)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 5 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "named: entityLoad(name, id, options)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 6 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "named: entityLoad(name, id)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 7 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "named: entityLoad(name, options)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 8 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "named: entityLoad(name, unique)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 9 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

			it( "named: entityLoad(name, id, unique)", function() {
				var result = _InternalRequest( template: "#uri#/test.cfm", forms: { scene: 10 } );
				expect( trim( result.filecontent ) ).toBe( true );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
