component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM custom hbm.xml mapping (autogenmap=false)", function() {

			it( "uses hand-written hbm.xml for custom table and column names", function() {
				var result = _InternalRequest( template: "#uri()#/index.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "customHbmXml";
	}

}
