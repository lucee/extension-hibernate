component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Native ID immediate insert [H2]", function() {

			it( "generator=identity inserts immediately on entitySave, before ormFlush", function() {
				var result = _InternalRequest( template: "#uri()#/immediateInsert.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "nativeIdInsert";
	}

}
