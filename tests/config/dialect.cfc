component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Dialect string resolution [H2]", function() {

			it( "auto-detect dialect (no dialect specified)", function() {
				var result = _InternalRequest(
					template: "#uri()#/verify.cfm",
					urls: { testDialect: "" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "short name: H2", function() {
				var result = _InternalRequest(
					template: "#uri()#/verify.cfm",
					urls: { testDialect: "H2" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "full class name: org.hibernate.dialect.H2Dialect", function() {
				var result = _InternalRequest(
					template: "#uri()#/verify.cfm",
					urls: { testDialect: "org.hibernate.dialect.H2Dialect" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "case-insensitive short name: h2", function() {
				var result = _InternalRequest(
					template: "#uri()#/verify.cfm",
					urls: { testDialect: "h2" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "dialect";
	}

}
