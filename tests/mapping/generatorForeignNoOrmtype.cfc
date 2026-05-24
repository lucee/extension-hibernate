component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "generator='foreign' without explicit ormtype on the id (LDEV-6343)", function() {

			it( "child id type resolves to parent's id type (integer), FK constraint creates, round-trip works", function() {
				var result = _InternalRequest( template: "#uri()#/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "generatorForeignNoOrmtype";
	}

}
