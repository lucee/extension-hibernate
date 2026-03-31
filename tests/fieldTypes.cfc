component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM field types", function() {

			it( "default values and persistence for timezone, string, boolean, integer, int, date, timestamp", function() {
				var result = _InternalRequest( template: "#uri()#/types.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "string truncation throws on value exceeding length", function() {
				var result = _InternalRequest( template: "#uri()#/stringTruncate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "notnull, insert=false, update=false, empty default constraints", function() {
				var result = _InternalRequest( template: "#uri()#/constraints.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "fieldTypes";
	}

}
