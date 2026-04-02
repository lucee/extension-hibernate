component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( title="ORM ID generators [mssql]", skip=notHasMssql(), body=function() {

			it( "generator=assigned requires caller-provided ID", function() {
				var result = _InternalRequest( template: "#uri()#/assigned.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "generator=uuid produces 32-char hex IDs", function() {
				var result = _InternalRequest( template: "#uri()#/uuid.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "generator=increment auto-increments from max(id)+1", function() {
				var result = _InternalRequest( template: "#uri()#/increment.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "generator=identity uses DB auto-increment", function() {
				var result = _InternalRequest( template: "#uri()#/identity.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "generator=native delegates to DB-appropriate strategy", function() {
				var result = _InternalRequest( template: "#uri()#/native.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "generator=guid produces 36-char DB-generated GUID", function() {
				var result = _InternalRequest( template: "#uri()#/guid.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "generators";
	}

	private boolean function notHasMssql() {
		return isEmpty( server.getDatasource( "mssql" ) );
	}

}
