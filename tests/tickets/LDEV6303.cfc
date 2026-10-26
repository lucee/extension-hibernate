component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {
		describe( "LDEV-6303 expression defaults for NULL columns", function() {

			it( "an entity loaded from a row with NULL columns gets its expression defaults", function() {
				local.result = _InternalRequest( template: "#createURI( 'LDEV6303' )#/test.cfm" );
				local.data = deserializeJSON( trim( result.filecontent ) );
				expect( data.nullLiteral ).toBe( "literal" );
				expect( data.nullExpr ).toBe( "xxx" );
				expect( data.nullExprNumber ).toBe( 3 );
			});

			it( "columns with a value are not replaced by the defaults", function() {
				local.result = _InternalRequest( template: "#createURI( 'LDEV6303' )#/test.cfm" );
				local.data = deserializeJSON( trim( result.filecontent ) );
				expect( data.valueLiteral ).toBe( "a" );
				expect( data.valueExpr ).toBe( "b" );
				expect( data.valueExprNumber ).toBe( 7 );
			});

		});
	}

	private string function createURI( string calledName ) {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & calledName;
	}

}
