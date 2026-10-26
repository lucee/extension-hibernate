component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV717" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-717 entity names are listed in alphabetical order", function() {

			it( "the 'available entities' list in the error for an unknown entity is sorted", function() {
				local.result = _InternalRequest( template: "#uri#/unknownEntity.cfm" );
				expect( result.filecontent ).toInclude( "available entities are [apple, Banana, Kiwi, Mango, Zebra]" );
			});

			it( "entityNameList() is sorted", function() {
				local.result = _InternalRequest( template: "#uri#/entityNameList.cfm" );
				expect( trim( result.filecontent ) ).toBe( "apple,Banana,Kiwi,Mango,Zebra" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
