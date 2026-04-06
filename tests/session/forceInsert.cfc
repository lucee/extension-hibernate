component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "forceInsert and generated ID [H2]", function() {

			it( "forceInsert with identity generator populates ID", function() {
				var result = _InternalRequest( template: "#uri()#/forceInsertIdentity.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "forceInsert with assigned generator preserves ID", function() {
				var result = _InternalRequest( template: "#uri()#/forceInsertAssigned.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "save new entity without forceInsert populates ID", function() {
				var result = _InternalRequest( template: "#uri()#/saveNewEntity.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "save existing entity (update) preserves ID", function() {
				var result = _InternalRequest( template: "#uri()#/updateExisting.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "forceInsert";
	}

}
