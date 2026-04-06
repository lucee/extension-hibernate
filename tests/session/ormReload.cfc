component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORMReload [H2]", function() {

			it( "ormReload rebuilds mappings and entities work after", function() {
				var result = _InternalRequest( template: "#uri()#/reloadRebuildsMappings.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "ormReload";
	}

}
