component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM schema modes", function() {

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

			it( "validate throws on schema mismatch", function() {
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

}
