component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "autoManageSession=false [H2]", function() {

			it( "requires explicit ormFlush to persist", function() {
				var result = _InternalRequest( template: "#uri()#/manualFlush.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "autoManageSession";
	}

}
