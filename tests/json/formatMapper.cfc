component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "formatMapper" );
	}

	function run( testResults, testBox ) {
		describe( "JSON format mapper on SessionFactory startup", function() {

			it( "ormGetSessionFactory() boots and uses Hibernate's Jackson JSON format mapper", function() {
				local.result = _InternalRequest( template: "#uri#/mapperName.cfm" );
				expect( trim( result.filecontent ) ).toBe( "org.hibernate.type.format.jackson.JacksonJsonFormatMapper" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
