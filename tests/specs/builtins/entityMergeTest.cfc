component extends="testbox.system.BaseSpec" {

	function beforeAll(){
		variables.testEntity = entityNew( "Auto", { make : "Ford", id : createUUID() } );
		entitySave( variables.testEntity );
		ormFlush();
	}
	function afterAll(){
		ormClearSession();
		queryExecute( "DELETE from Auto WHERE make='Ford'" );
	}

	public void function run(){
		/**
		 * For a better explanation of what this test is doing,
		 * see https://docs.jboss.org/hibernate/orm/5.4/userguide/html_single/Hibernate_User_Guide.html#pc-merge
		 */
		describe( "entityMerge()", () => {
			it( "will merge modified, detached entity back into session", () => {
				var detachedAutoEntity = entityLoadByPK( "Auto", testEntity.getId() );

				// make a change but don't save it
				detachedAutoEntity.setModel( "Fusion" );

				// clear session - will "detach" the entity
				ormClearSession();

				// "merge" it back to the session
				var merged = entityMerge( detachedAutoEntity );

				// changes should be reflected in the new entity
				expect( merged.getModel() ).toBe( "Fusion" );
			} );
		} );
	}

}