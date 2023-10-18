component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "entitySave()", () => {
			beforeEach( () => {
				queryExecute( "DELETE FROM Auto" );
			} );

			it( "can save a new entity", () => {
				var myCar = entityNew( "Auto", { make : "Toyota", id : createUUID() } );
				entitySave( myCar );
				ormFlush();
				expect( queryExecute( "SELECT id FROM Auto" ).recordCount ).toBe( 1 );
			} );

			// We have SO many entitySave() tests, do we need this?
			it( "can save an existing entity", () => {
				var myCar = entityNew( "Auto", { make : "Toyota", id : createUUID() } );
				entitySave( myCar );
				ormFlush();
				expect( queryExecute( "SELECT id FROM Auto" ).recordCount ).toBe( 1 );

				myCar.setModel( "Rav4" );
				entitySave( myCar );
				ormFlush();
				expect( queryExecute( "SELECT id FROM Auto" ).recordCount ).toBe( 1 );
				expect( queryExecute( "SELECT model FROM Auto" ).model[ 1 ] ).toBe( "Rav4" );
			} );

			/**
			 * Then we can actually see if Hibernate will force the insert. Currently, even the `session.save()` will match on the identifier.
			 *
			 * @TODO: Re-implement this test against an entity with a different identifier generator type.
			 */
			xit( "can forceInsert=true", () => {
				var myCar = entityLoad( "Auto", { make : "Ford" }, true );
				entitySave( myCar, true );
				expect( queryExecute( "SELECT id FROM Auto" ).recordCount ).toBe( 2 );
			} );

			it( "can forceInsert=false", () => {
				var myCar = entityNew( "Auto", { make : "Ford", model : "Fusion", id : createUUID() } );
				entitySave( myCar, false );
				ormFlush();
				expect( queryExecute( "SELECT id FROM Auto" ).recordCount ).toBe( 1 );
			} );
		} );
	}

}
