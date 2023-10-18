component extends="testbox.system.BaseSpec" {

	function beforeAll(){
		variables.testEntity = entityNew( "Auto", { make : "Lamborghini", model : "Aventador", id : createUUID() } );
		entitySave( variables.testEntity );
		ormFlush();
	}
	function afterAll(){
		ormClearSession();
		queryExecute( "DELETE from Auto WHERE make='Lamborghini'" );
	}

	public void function run(){
		/**
		 * For a better explanation of what this test is doing,
		 * see https://docs.jboss.org/hibernate/orm/5.4/userguide/html_single/Hibernate_User_Guide.html#pc-merge
		 */
		describe( "entityReload()", () => {
			it( "will reload entity from session", () => {
				var myCar = entityLoadByPK( "Auto", testEntity.getId() );

				// make a change but don't save it
				myCar.setModel( "Revuelto" );

				// reload the entity
				entityReload( myCar );

				// our local changes should be replaced with the DB value
				expect( myCar.getModel() ).toBe( "Aventador" );
			} );
		} );
	}

}