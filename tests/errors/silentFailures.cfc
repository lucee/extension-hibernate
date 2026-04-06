component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM metadata validation", function() {

			it( "bad collectionType throws error with entity and property context", function() {
				try {
					var result = _InternalRequest( template: "#uri()#/badCollectionType/test.cfm" );
					var msg = trim( result.filecontent );
				} catch ( any e ) {
					var msg = e.message;
				}
				// should fail at ORM init, not silently ignore
				expect( msg ).notToInclude( "SILENT" );
				expect( msg ).toInclude( "collectiontype" );
				expect( msg ).toInclude( "badvalue" );
				expect( msg ).toInclude( "children" );
				expect( msg ).toInclude( "Parent" );
			});

			it( "bad ormtype throws error at init instead of ClassCastException at DB layer", function() {
				try {
					var result = _InternalRequest( template: "#uri()#/badOrmType/test.cfm" );
					var msg = trim( result.filecontent );
				} catch ( any e ) {
					var msg = e.message;
				}
				// should fail at ORM init, not silently ignore
				expect( msg ).notToInclude( "SILENT" );
				expect( msg ).toInclude( "garbage" );
				expect( msg ).toInclude( "score" );
			});

			it( "bad fetch value throws error with property context", function() {
				try {
					var result = _InternalRequest( template: "#uri()#/badFetchValue/test.cfm" );
					var msg = trim( result.filecontent );
				} catch ( any e ) {
					var msg = e.message;
				}
				expect( msg ).notToInclude( "SILENT" );
				expect( msg ).toInclude( "fetch" );
				expect( msg ).toInclude( "bogus" );
			});

			it( "bad lazy value throws error with property context", function() {
				try {
					var result = _InternalRequest( template: "#uri()#/badLazyValue/test.cfm" );
					var msg = trim( result.filecontent );
				} catch ( any e ) {
					var msg = e.message;
				}
				expect( msg ).notToInclude( "SILENT" );
				expect( msg ).toInclude( "lazy" );
				expect( msg ).toInclude( "bogus" );
			});

			it( "collection without elementtype throws error at init", function() {
				try {
					var result = _InternalRequest( template: "#uri()#/missingElementType/test.cfm" );
					var msg = trim( result.filecontent );
				} catch ( any e ) {
					var msg = e.message;
				}
				expect( msg ).notToInclude( "SILENT" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "silentFailures";
	}

}
