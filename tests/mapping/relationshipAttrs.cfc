component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Relationship property attributes [H2]", function() {

			it( "readonly=true: collection loads correctly", function() {
				var result = _InternalRequest( template: "#uri()#/readonlyCollection.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "notnull=true on many-to-one FK: null FK throws constraint violation", function() {
				var result = _InternalRequest( template: "#uri()#/notnullFK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "update=false on many-to-one FK: category change not persisted", function() {
				var result = _InternalRequest( template: "#uri()#/updateFalseFK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "unique=true + uniquekey on many-to-one: second FK duplicate throws", function() {
				var result = _InternalRequest( template: "#uri()#/uniqueKeyFK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "mappedby on many-to-one: FK references non-PK unique column", function() {
				var result = _InternalRequest( template: "#uri()#/mappedbyNonPK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "insert=true, update=false combo: FK set on insert, not changeable after", function() {
				var result = _InternalRequest( template: "#uri()#/insertTrueUpdateFalse.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "relationshipAttrs";
	}

}
