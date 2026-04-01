component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( title="ORM transactions [mysql]", skip=notHasMySQL(), body=function() {

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

	private boolean function notHasMySQL() {
		return isEmpty( server.getDatasource( "mysql" ) );
	}

}
