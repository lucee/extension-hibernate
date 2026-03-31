component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM flush behaviour (flushAtRequestEnd=false)", function() {

			it( "entitySave without ormFlush does NOT persist to DB", function() {
				var result = _InternalRequest( template: "#uri()#/noAutoFlush.cfm" );
				expect( trim( result.filecontent ) ).toBe( "rows=0" );
			});

			it( "explicit ormFlush persists to DB", function() {
				var result = _InternalRequest( template: "#uri()#/explicitFlush.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "flushBehaviour";
	}

}
