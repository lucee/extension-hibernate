component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "dbcreate=validate [MySQL]", function() {

			it( title="baseline: dropcreate creates schema, entity round-trips", skip="#notHasMysql()#", body=function() {
				var result = _InternalRequest(
					template: "#uri()#/test.cfm",
					urls: { dbcreate: "dropcreate" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			// LDEV-6239: dbcreate="validate" must reject entities mapped to non-existent tables
			it( title="validate mode rejects entity mapped to non-existent table", skip="#notHasMysql()#", body=function() {
				// first, ensure some schema exists via dropcreate
				_InternalRequest(
					template: "#uri()#/test.cfm",
					urls: { dbcreate: "dropcreate" }
				);
				// drop the mismatch table in case dropcreate created it (recursive cfclocation scan)
				queryExecute( "DROP TABLE IF EXISTS SV_DOES_NOT_EXIST", {}, { datasource: server.getDatasource( "mysql" ) } );
				// now hit mismatch sub-app — entity maps to SV_DOES_NOT_EXIST table
				try {
					var result = _InternalRequest( template: "#uri()#/mismatch/test.cfm" );
					var msg = trim( result.filecontent );
				} catch ( any e ) {
					var msg = e.message;
				}
				// should fail at ORM init, not silently ignore
				expect( msg ).notToInclude( "SILENT" );
			});

		});

	}

	private boolean function notHasMysql() {
		return isEmpty( server.getDatasource( "mysql" ) );
	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "schemaValidate";
	}

}
