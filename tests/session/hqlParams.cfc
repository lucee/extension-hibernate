component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "HQL typed parameter binding [H2]", function() {

			it( "named string parameter", function() {
				var result = _InternalRequest( template: "#uri()#/namedString.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "named integer parameter", function() {
				var result = _InternalRequest( template: "#uri()#/namedInteger.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "named decimal parameter", function() {
				var result = _InternalRequest( template: "#uri()#/namedDecimal.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "named boolean parameter", function() {
				var result = _InternalRequest( template: "#uri()#/namedBoolean.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "named date parameter", function() {
				var result = _InternalRequest( template: "#uri()#/namedDate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "positional string parameter", function() {
				var result = _InternalRequest( template: "#uri()#/positionalString.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "multiple positional parameters", function() {
				var result = _InternalRequest( template: "#uri()#/positionalMultiple.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "string collection parameter (IN clause)", function() {
				var result = _InternalRequest( template: "#uri()#/collectionString.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "numeric collection parameter (IN clause)", function() {
				var result = _InternalRequest( template: "#uri()#/collectionNumeric.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "DML update with typed params", function() {
				var result = _InternalRequest( template: "#uri()#/dmlUpdate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "DML delete with param (no matching rows)", function() {
				var result = _InternalRequest( template: "#uri()#/dmlDelete.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "unique=true with named param", function() {
				var result = _InternalRequest( template: "#uri()#/uniqueWithParam.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "params combined with options (maxresults)", function() {
				var result = _InternalRequest( template: "#uri()#/paramsWithOptions.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "hqlParams";
	}

}
