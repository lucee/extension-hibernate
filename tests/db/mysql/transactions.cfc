component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		if ( isEmpty( server.getDatasource( "mysql" ) ) )
			throw( type="org.lucee.cfml.test.LuceeTestCase.SkipTest", message="mysql not configured" );
	}

	function run( testResults, testBox ) {

		describe( "ORM transactions [mysql]", function() {

			it( "can roll back entire transaction", function() {
				var result = _InternalRequest( template: "#uri()#/rollback.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "can commit entire transaction", function() {
				var result = _InternalRequest( template: "#uri()#/commit.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "implicit commit on transaction block end", function() {
				var result = _InternalRequest( template: "#uri()#/implicitCommit.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "rollback reverts all flushed changes", function() {
				var result = _InternalRequest( template: "#uri()#/nestedRollback.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "transaction with isolation=serializable", function() {
				var result = _InternalRequest( template: "#uri()#/isolationSerializable.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "transaction with isolation=read_committed", function() {
				var result = _InternalRequest( template: "#uri()#/isolationReadCommitted.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "transactions";
	}

}
