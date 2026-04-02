component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM error messages", function() {

			it( "entityNew with missing entity throws helpful error", function() {
				var result = _InternalRequest( template: "#uri()#/missingEntity.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormExecuteQuery with bad HQL throws error", function() {
				var result = _InternalRequest( template: "#uri()#/badHQL.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entity names are case-insensitive", function() {
				var result = _InternalRequest( template: "#uri()#/wrongCaseEntity.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityToQuery with non-entity gives helpful error", function() {
				var result = _InternalRequest( template: "#uri()#/badEntityToQuery.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "errorMessages";
	}

}
