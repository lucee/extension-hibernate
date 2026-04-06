component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "dynamicinsert / dynamicupdate attributes [H2]", function() {

			it( "dynamicInsert=true entity saves correctly with null properties", function() {
				var result = _InternalRequest( template: "#uri()#/dynamicInsert.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "dynamicUpdate=true: partial update preserves untouched properties", function() {
				var result = _InternalRequest( template: "#uri()#/dynamicUpdate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "dynamicSQL";
	}

}
