component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "entity preInsert events", function() {

			it( "preInsert changes and persists entity state", function() {
				var result = _InternalRequest( template: "#uri()#/preInsert.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "preInsert persists date value state changes (OOE-9)", function() {
				var result = _InternalRequest( template: "#uri()#/preInsertDate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "preInsert can auto-set notnull field to prevent constraint violation (OOE-12)", function() {
				var result = _InternalRequest( template: "#uri()#/preInsertNotnull.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "null notnull field still throws when preInsert doesn't fix it (OOE-12)", function() {
				var result = _InternalRequest( template: "#uri()#/preInsertNotnullThrows.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "preInsert can mutate property on parent entity (OOE-14)", function() {
				var result = _InternalRequest( template: "#uri()#/preInsertParent.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

		describe( "entity preUpdate events", function() {

			it( "preUpdate changes and persists entity state", function() {
				var result = _InternalRequest( template: "#uri()#/preUpdate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "preUpdate persists date value state changes (OOE-9)", function() {
				var result = _InternalRequest( template: "#uri()#/preUpdateDate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "preUpdate can auto-set notnull field (OOE-12)", function() {
				var result = _InternalRequest( template: "#uri()#/preUpdateNotnull.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "preUpdate can mutate property on parent entity (OOE-14)", function() {
				var result = _InternalRequest( template: "#uri()#/preUpdateParent.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "entityEvents";
	}

}
