component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM cfclocation support", function() {

			it( "discovers entities across multiple cfclocation directories", function() {
				var result = _InternalRequest( template: "#uri()#/multipleDirectories.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "LDEV-1697: handles overlapping parent + child cfclocation entries without duplicate registration", function() {
				var result = _InternalRequest( template: "#uri()#/parentChildOverlap/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cfclocation";
	}

}
