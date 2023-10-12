component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll(){
		variables.newEntity = entityNew( "Auto", { make : "Ford", id : createUUID() } );
		entitySave( newEntity );
		ormFlush();
	}

	function run( testResults, testBox ){
		// TODO: Fix Me!
		// https://luceeserver.atlassian.net/browse/LDEV-2859
		var isResolved = FALSE;

		describe(
			title = "test suite for LDEV2859",
			body  = function(){
				it( "Orm entitytoquery without name", () => {
					var entity = entityLoad( "Auto", variables.newEntity.getId() );
					var entityAsQuery = entitytoquery(entity);
					expect( entityAsQuery.make[1] ).toBe( "Ford" );
				} );

				it( "Orm entitytoquery with entityName", () => {
					var entity = entityLoad( "Auto", variables.newEntity.getId() );
					var entityAsQuery = entitytoquery(entity, "Auto");
					expect( entityOut.make[1] ).toBe( "Ford" );
				} );
			},
			skip = !isResolved
		);
	}

}
