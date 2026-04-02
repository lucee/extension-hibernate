component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV4339" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-4339 ORM sessions in threads are closed automatically", function() {

			it( "thread sessions closed (autoManageSession=true, flushAtRequestEnd=true)", function() {
				local.result = _InternalRequest(
					template: "#uri#/test.cfm",
					url: {
						autoManageSession: true,
						flushAtRequestEnd: true
					}
				);
				var counts = listToArray( trim( result.filecontent ), ":" );
				expect( counts[ 1 ] ).toBe( counts[ 2 ], "openCount (#counts[ 1 ]#) should equal closeCount (#counts[ 2 ]#)" );
			});

			it( "thread sessions closed (autoManageSession=false, flushAtRequestEnd=false)", function() {
				local.result = _InternalRequest(
					template: "#uri#/test.cfm",
					url: {
						autoManageSession: false,
						flushAtRequestEnd: false
					}
				);
				var counts = listToArray( trim( result.filecontent ), ":" );
				expect( counts[ 1 ] ).toBe( counts[ 2 ], "openCount (#counts[ 1 ]#) should equal closeCount (#counts[ 2 ]#)" );
			});

		});
	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
