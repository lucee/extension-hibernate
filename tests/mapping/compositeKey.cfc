component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Composite primary keys [H2]", function() {

			it( "load by composite PK via entityLoad filter", function() {
				var result = _InternalRequest( template: "#uri()#/loadByPK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "save new entity with composite PK", function() {
				var result = _InternalRequest( template: "#uri()#/saveNew.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "delete entity with composite PK", function() {
				var result = _InternalRequest( template: "#uri()#/deleteByPK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "unique load by composite PK filter", function() {
				var result = _InternalRequest( template: "#uri()#/uniqueLoad.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "HQL with composite key fields", function() {
				var result = _InternalRequest( template: "#uri()#/hqlWithCompositeFields.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "compositeKey";
	}

}
