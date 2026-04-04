component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM transactions [H2 — basic plumbing only]", function() {

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

			it( "transaction end() commits active transaction", function() {
				var result = _InternalRequest( template: "#uri()#/endAfterCommit.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityDelete within transaction block", function() {
				var result = _InternalRequest( template: "#uri()#/deleteInTransaction.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityDelete array within transaction block", function() {
				var result = _InternalRequest( template: "#uri()#/deleteArrayInTransaction.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "LDEV-6206: transactionCommit creates durable checkpoint", function() {
				var result = _InternalRequest( template: "#uri()#/facadeIsNoOp.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORM outside transaction block auto-commits", function() {
				var result = _InternalRequest( template: "#uri()#/ormOutsideTransaction.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "transactions";
	}

}
