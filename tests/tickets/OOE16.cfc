component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "OOE-16 / LDEV-87: persistent='false' override on MappedSuperClass property", function() {

			xit( "child entity can override parent property with persistent=false", function() {
				var result = _InternalRequest( template: "#uri()#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "OOE16";
	}

}
