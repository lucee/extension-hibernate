component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV91" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-91 mappedSuperClass with the same file name as the child entity", function() {

			it( "ORM initialises and the entity inherits the mappedSuperClass properties", function() {
				local.result = _InternalRequest( template: "#uri#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormReload() works", function() {
				local.result = _InternalRequest( template: "#uri#/reload.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
