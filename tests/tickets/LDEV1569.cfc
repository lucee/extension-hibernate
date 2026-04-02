component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uriNullOff = createURI( "LDEV1569-nulloff" );
		variables.uriNullOn = createURI( "LDEV1569-nullon" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-1569 serializeJSON with NULL properties — nullSupport=false", function() {

			it( "documents current behaviour: ORM entity omits null properties", function() {
				var data = runTest( uriNullOff );
				// ACF also omits — this is consistent across engines
				expect( data.orm_hasDescription ).toBeFalse( "ORM null property should be omitted when nullSupport=false" );
			});

			it( "documents current behaviour: non-persistent CFC omits unset properties", function() {
				var data = runTest( uriNullOff );
				expect( data.dto_hasDescription ).toBeFalse( "DTO unset property should be omitted when nullSupport=false" );
			});

			it( "documents current behaviour: non-persistent CFC omits explicit null", function() {
				var data = runTest( uriNullOff );
				expect( data.dto_explicitNull_hasDescription ).toBeFalse( "DTO explicit null should be omitted when nullSupport=false" );
			});

			it( "non-persistent CFC includes all set properties", function() {
				var data = runTest( uriNullOff );
				expect( data.dto_allSet_hasDescription ).toBeTrue( "DTO with value set should include property" );
			});

			// ACF includes null in plain structs, Lucee drops it — line 379 in JSONConverter.java
			xit( "plain struct includes null as null", function() {
				var data = runTest( uriNullOff );
				expect( data.struct_hasDescription ).toBeTrue( "struct null should be included" );
			});

		});

		describe( "LDEV-1569 serializeJSON with NULL properties — nullSupport=true", function() {

			xit( "ORM entity includes null property as null", function() {
				var data = runTest( uriNullOn );
				expect( data.orm_hasDescription ).toBeTrue( "ORM null property should be included when nullSupport=true" );
			});

			xit( "non-persistent CFC includes unset property as null", function() {
				var data = runTest( uriNullOn );
				expect( data.dto_hasDescription ).toBeTrue( "DTO unset property should be included when nullSupport=true" );
			});

			xit( "non-persistent CFC includes explicit null as null", function() {
				var data = runTest( uriNullOn );
				expect( data.dto_explicitNull_hasDescription ).toBeTrue( "DTO explicit null should be included when nullSupport=true" );
			});

			it( "non-persistent CFC includes all set properties", function() {
				var data = runTest( uriNullOn );
				expect( data.dto_allSet_hasDescription ).toBeTrue( "DTO with value set should include property" );
			});

			xit( "plain struct includes null as null", function() {
				var data = runTest( uriNullOn );
				expect( data.struct_hasDescription ).toBeTrue( "struct null should be included" );
			});

		});
	}

	private struct function runTest( required string uri ) {
		var result = _InternalRequest( template: "#uri#/test.cfm" );
		expect( result.filecontent ).toBeJSON();
		return deserializeJSON( result.filecontent );
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
