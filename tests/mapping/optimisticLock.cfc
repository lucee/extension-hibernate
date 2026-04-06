component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "optimisticlock attribute [H2]", function() {

			it( "entity with optimisticlock=all round-trips updates correctly", function() {
				var result = _InternalRequest( template: "#uri()#/optimisticLockAll.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "optimisticLock";
	}

}
