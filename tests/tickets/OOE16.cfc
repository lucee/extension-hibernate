component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "OOE-16 / LDEV-87: persistent='false' override on MappedSuperClass property", function() {

			it( "child entity can override parent property with persistent=false", function() {
				var result = _InternalRequest( template: "#uri()#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "child entity that does NOT override keeps inherited property", function() {
				var result = _InternalRequest( template: "#uri()#/testKeeps.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "OOE16";
	}

}
