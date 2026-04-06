component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "fetch attribute (join/select) [H2]", function() {

			it( "fetch=join on one-to-many loads articles with author", function() {
				var result = _InternalRequest( template: "#uri()#/fetchJoin.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "fetch=select on many-to-one loads author separately", function() {
				var result = _InternalRequest( template: "#uri()#/fetchSelect.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "fetchStrategy";
	}

}
