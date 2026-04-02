component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV119" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-119 ORMReload() under concurrent load", function() {

			it( "should not NPE when threads are using ORM during reload", function() {
				local.result = _InternalRequest(
					template: "#uri#/reloadUnderLoad.cfm"
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
