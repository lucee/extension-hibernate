component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "entity event listeners()", () => {
			describe( "preInsert", () => {
				it( "runs preInsert on ORMFlush to change and persist entity state", () => {
					var newCar = entityNew( "Auto", { id : createUUID(), make : "BMW" } );
					expect( newCar.getInserted() ).toBeFalse();
					entitySave( newCar );
					expect( newCar.getInserted() ).toBeFalse();
					ormFlush();
					expect( newCar.getInserted() ).toBeTrue( "preInsert should update 'inserted' boolean" );
					var theID = newCar.getId();
	
					ormClearSession();
					var persistedCar = entityLoadByPK( "Auto", theID );
					expect( persistedCar.getInserted() ).toBeTrue( "persisted value should be true" );
				} );
				it( "runs preInsert on transaction end to change and persist entity state", () => {
					transaction{
						var newCar = entityNew( "Auto", { id : createUUID(), make : "Audi" } );
						expect( newCar.getInserted() ).toBeFalse();
						entitySave( newCar );
						expect( newCar.getInserted() ).toBeFalse();
					}
					expect( newCar.getInserted() ).toBeTrue( "preInsert should update 'inserted' boolean" );
					var theID = newCar.getId();
	
					ormClearSession();
					var persistedCar = entityLoadByPK( "Auto", theID );
					expect( persistedCar.getInserted() ).toBeTrue( "persisted value should be true" );
				} );
			});
			describe( "preUpdate", () => {
				it( "runs preUpdate on ORMFlush to change and persist entity state", () => {
					var newCar = entityNew( "Auto", { id : createUUID(), make : "Audi" } );
					expect( newCar.getUpdated() ).toBeFalse();
					entitySave( newCar );
					ormFlush();
					expect( newCar.getUpdated() ).toBeFalse();
					newCar.setModel( "A5" );

					entitySave( newCar );
					ormFlush();

					expect( newCar.getUpdated() ).toBeTrue( "preUpdate should update 'updated' boolean" );
					var theID = newCar.getId();

					ormClearSession();
					var persistedCar = entityLoadByPK( "Auto", theID );
					expect( persistedCar.getUpdated() ).toBeTrue( "persisted value should be true" );
				} );
				it( "runs preUpdate on transaction end to change and persist entity state", () => {
					var newCar = entityNew( "Auto", { id : createUUID(), make : "Audi" } );
					expect( newCar.getUpdated() ).toBeFalse();
					entitySave( newCar );
					ormFlush();
					expect( newCar.getUpdated() ).toBeFalse();
					transaction{
						newCar.setModel( "A5" );
					}

					expect( newCar.getUpdated() ).toBeTrue( "preUpdate should update 'updated' boolean" );
					var theID = newCar.getId();

					ormClearSession();
					var persistedCar = entityLoadByPK( "Auto", theID );
					expect( persistedCar.getUpdated() ).toBeTrue( "persisted value should be true" );
				} );
			});
		} );
	}

}
