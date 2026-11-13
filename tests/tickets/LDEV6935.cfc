component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV6935" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-6935 failed ORM flush must not leave a Hibernate transaction active", function() {

			it( "a later transaction{} in the same request still works after a failed flush", function() {
				var result = _InternalRequest( template: "#uri#/failedFlushThenSave.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormClearSession() recovers after a failed flush so a later transaction{} works", function() {
				var result = _InternalRequest( template: "#uri#/failedFlushClearThenSave.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});
	}

	private string function createURI( string calledName ) {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & calledName;
	}

}
