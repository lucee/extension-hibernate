/**
 * dbcreate=update with schema changes: verify that adding a new property
 * to an entity causes the column to be added, while preserving existing data.
 *
 * Phase 1: dropcreate with v1 entity (id, name), insert a row
 * Phase 2: update with v2 entity (id, name, description), verify old data
 *          survived and new column is usable
 *
 * HHH-10882 (H2 SchemaUpdate silently generating no DDL when no default_schema
 * was set) is fixed in Hibernate 7.3 — works correctly on H2/MySQL/PostgreSQL/MSSQL.
 */
component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "dbcreate=update with schema changes (H2)", function() {

			it( "adding a property updates the schema and preserves data", function() {
				var setup = _InternalRequest(
					template: "#uri()#/setup.cfm",
					url: { phase: 1, db: "h2" }
				);
				expect( trim( setup.filecontent ) ).toBe( "ok" );

				var verify = _InternalRequest(
					template: "#uri()#/verify.cfm",
					url: { phase: 2, db: "h2" }
				);
				expect( trim( verify.filecontent ) ).toBe( "ok" );
			});

		});

		describe( "dbcreate=update with schema changes (MySQL)", function() {

			it( title="adding a property updates the schema and preserves data",
				skip="#notHasMysql()#",
				body=function() {
				var setup = _InternalRequest(
					template: "#uri()#/setup.cfm",
					url: { phase: 1, db: "mysql" }
				);
				expect( trim( setup.filecontent ) ).toBe( "ok" );

				var verify = _InternalRequest(
					template: "#uri()#/verify.cfm",
					url: { phase: 2, db: "mysql" }
				);
				expect( trim( verify.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private function notHasMysql() {
		return structCount( server.getDatasource( "mysql" ) ) == 0;
	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "schemaUpdate";
	}

}
