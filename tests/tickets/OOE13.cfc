component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "OOE-13: transaction block with early return (Lucee core bug)", function() {

			it( "transaction with return inside commits and releases locks", function() {
				var result = _InternalRequest( template: "#uri()#/earlyReturn.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "OOE13";
	}

}
