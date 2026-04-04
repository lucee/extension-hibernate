component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( title="ORM transactions [postgres]", skip=notHasPostgres(), body=function() {

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

			it( "LDEV-6203: ORM does not force SERIALIZABLE on regular queryExecute connections", function() {
				var result = _InternalRequest( template: "#uri()#/isolationLeakToQueryExecute.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "mixed ORM + queryExecute commit and rollback together", function() {
				var result = _InternalRequest( template: "#uri()#/mixedOrmAndQuery.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "rollback reverts flushed ORM changes (LDEV-966 regression)", function() {
				var result = _InternalRequest( template: "#uri()#/rollbackAfterFlush.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "rollback reverts multiple sequential flushes", function() {
				var result = _InternalRequest( template: "#uri()#/rollbackMultipleFlushes.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "commit then rollback — commit survives, rollback reverts rest", function() {
				var result = _InternalRequest( template: "#uri()#/commitThenRollback.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "exception mid-transaction rolls back all changes", function() {
				var result = _InternalRequest( template: "#uri()#/errorMidTransaction.cfm" );
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

			it( "LDEV-6207: isWithinORMTransaction() detects Hibernate transaction state", function() {
				var result = _InternalRequest( template: "#uri()#/isWithinORMTransaction.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "LDEV-6205: cftransaction isolation is honoured by ORM connection", function() {
				var result = _InternalRequest( template: "#uri()#/isolationHonouredByORM.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "transactions";
	}

	private boolean function notHasPostgres() {
		return isEmpty( server.getDatasource( "postgres" ) );
	}

}
