component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		// `cascade="evict"` was a CascadeStyle in H5; H6 dropped it.
		describe( "cascade='evict' (H5 only — removed in Hibernate 6+)", function() {

			it( "evict cascade is accepted at SF build", function() {
				var result = _InternalRequest( template: "#uri()#/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cascadeEvict";
	}

}
