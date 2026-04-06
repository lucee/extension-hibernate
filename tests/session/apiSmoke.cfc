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

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "apiSmoke";
	}

}
