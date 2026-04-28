component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Session API smoke tests [H2]", function() {

			it( "save + flush + loadByPK round-trip", function() {
				var result = _InternalRequest( template: "#uri()#/saveLoadRoundTrip.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "update existing entity round-trip", function() {
				var result = _InternalRequest( template: "#uri()#/updateRoundTrip.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "merge detached entity", function() {
				var result = _InternalRequest( template: "#uri()#/mergeDetached.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "delete entity", function() {
				var result = _InternalRequest( template: "#uri()#/deleteEntity.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormClearSession loads fresh from DB", function() {
				var result = _InternalRequest( template: "#uri()#/clearSession.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormGetSession().flush()", function() {
				var result = _InternalRequest( template: "#uri()#/sessionFlush.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormGetSession().clear()", function() {
				var result = _InternalRequest( template: "#uri()#/sessionClear.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormGetSession().isOpen() during request", function() {
				var result = _InternalRequest( template: "#uri()#/sessionIsOpen.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormGetSession().contains() after save", function() {
				var result = _InternalRequest( template: "#uri()#/sessionContains.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ORMGetSession() returns native Hibernate session with metadata API", function() {
				var result = _InternalRequest( template: "#uri()#/nativeSession.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "session.isDirty() and session.getIdentifier() detect changes", function() {
				var result = _InternalRequest( template: "#uri()#/dirtyProperties.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "session is open and tracks saved entities", function() {
				var result = _InternalRequest( template: "#uri()#/sessionStartsOnCRUD.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "getStatistics() returns entity and collection counts", function() {
				var result = _InternalRequest( template: "#uri()#/statisticsCounts.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "getDialect() returns the active SQL dialect", function() {
				var result = _InternalRequest( template: "#uri()#/getDialect.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "legacy SessionFactory metadata API (getDialect, getClassMetadata, getCollectionMetadata)", function() {
				var result = _InternalRequest( template: "#uri()#/legacyShim.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "apiSmoke";
	}

}
