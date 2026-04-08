component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		if ( notHasPostgres() ) return;
		variables.ds = server.getDatasource( "postgres" );
		try { queryExecute( "DROP TABLE IF EXISTS Item", {}, { datasource: variables.ds } ); } catch( any e ) {}
	}

	function run( testResults, testBox ) {

		describe( title="ORM schema modes [postgres]", skip=notHasPostgres(), body=function() {

			it( "dropcreate creates schema and allows CRUD", function() {
				var result = _InternalRequest( template: "#uri()#/dropcreate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "update creates missing tables without dropping", function() {
				var result = _InternalRequest(
					template: "#uri()#/update.cfm",
					url: { dbcreate: "update" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "none works against pre-existing schema", function() {
				var result = _InternalRequest(
					template: "#uri()#/none.cfm",
					url: { dbcreate: "none" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( title="validate throws on schema mismatch", skip=notSupported(), body=function() {
				try { queryExecute( "DROP TABLE IF EXISTS Item", {}, { datasource: variables.ds } ); } catch( any e ) {}
				try {
					var result = _InternalRequest(
						template: "#uri()#/validate.cfm",
						url: { dbcreate: "validate" }
					);
					var msg = trim( result.filecontent );
				} catch ( any e ) {
					var msg = e.message;
				}
				expect( msg ).toInclude( "missing table" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "schemaMode";
	}

	private boolean function notHasPostgres() {
		return isEmpty( server.getDatasource( "postgres" ) );
	}

	private boolean function notSupported() {
		return !server.checkVersionGTE( server.lucee.version, 7, 0, 4, 8 );
	}

}
