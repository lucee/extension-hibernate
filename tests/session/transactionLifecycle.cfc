component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Transaction session lifecycle [MySQL]", function() {

			it( title="transaction begin flushes existing dirty session", skip="#notHasMysql()#", body=function() {
				var result = _InternalRequest( template: "#uri()#/beginFlushesExisting.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( title="transaction rollback clears session — entity not in DB", skip="#notHasMysql()#", body=function() {
				var result = _InternalRequest( template: "#uri()#/rollbackClearsSession.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( title="transaction auto-commits when block ends without explicit commit/rollback", skip="#notHasMysql()#", body=function() {
				var result = _InternalRequest( template: "#uri()#/autoCommitOnEnd.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private boolean function notHasMysql() {
		return isEmpty( server.getDatasource( "mysql" ) );
	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "transactionLifecycle";
	}

}
