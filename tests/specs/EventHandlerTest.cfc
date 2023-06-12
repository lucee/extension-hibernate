component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "Global event listener (EventHandler.cfc)", () => {
			beforeEach( () => {
				variables.testAuto = entityNew( "Auto", { id : createUUID(), make : "Lexus" } );
				entitySave( variables.testAuto );
				ormFlush();
				application.ormEventLog = [];
			} );

			it( "emits pre/post insert events", () => {
				entitySave( entityNew( "Auto", { id : createUUID(), make : "BMW" } ) );
				ormFlush();
				// debug( application.ormEventLog );
				expect( application.ormEventLog.map( ( event ) => event.eventName ) ).toBe( [ "onFlush", "preInsert", "postInsert" ] );
			} );

			it( "emits pre/post update events", () => {
				variables.testAuto.setModel( "GX" );
				entitySave( variables.testAuto );
				ormFlush();
				// debug( application.ormEventLog );
				expect( application.ormEventLog.map( ( event ) => event.eventName ) ).toBe( [ "onFlush", "preUpdate", "postUpdate" ] );
			} );

			it( "emits pre/post delete events", () => {
				// should trigger preDelete, onDelete, and postDelete
				entityDelete( variables.testAuto );
				ormFlush();
				expect( application.ormEventLog.map( ( event ) => event.eventName ) ).toBe( [
					"onDelete",
					"onFlush",
					"preDelete",
					"postDelete"
				] );
			} );

			it( "emits pre/post load events", () => {
				// load events won't fire if Hibernate is merely returning an entity from the first-level cache (the session)
				ormClearSession();
				var entities = entityLoad( "Auto", variables.testAuto.getId() );

				expect( application.ormEventLog.map( ( event ) => event.eventName ) ).toBe( [ "onClear", "preLoad", "postLoad" ] );
			} );

			// TODO: Figure out why onEvict is not firing!
			xit( "emits onEvict", () => {
				ormEvictEntity( "Auto", variables.testAuto.getId() );
				expect( application.ormEventLog.map( ( event ) => event.eventName ) ).toBe( [ "onEvict" ] );
			} );

			it( "emits onClear", () => {
				ormClearSession();
				expect( application.ormEventLog.map( ( event ) => event.eventName ) ).toBe( [ "onClear" ] );
			} );
		} );
	}

}
