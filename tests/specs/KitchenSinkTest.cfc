/**
 * This test is intended to test a all supported field types.
 */
component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "Field Types", () => {
			beforeEach( () => {
				ormClearSession();
			} );
			describe( "+timezone", () => {
				it( "Can get the default value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getTimezone() ).toBe( "America/Los_Angelos" );
				} );
				it( "can set value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setTimeZone( "Pacific/Midway" );
					expect( sink.getTimeZone() ).toBe( "Pacific/Midway" );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getTimeZone() ).toBe( "Pacific/Midway" );
				} );
			} );
			describe( "+string", () => {
				it( "Can get the default value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getString() ).toBe( "johnwhish" );
				} );
				it( "can set value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setString( "new" );
					expect( sink.getString() ).toBe( "new" );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getString() ).toBe( "new" );
				} );
				it( "truncates past length", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setString( "thisisjusttoolong" );
					expect( sink.getString() ).toBe( "thisisjusttoolong" );
					expect( () => {
						entitySave( sink );
						ormFlush();
					} ).toThrow( "javax.persistence.PersistenceException" );
				} );
			} );
			describe( "+boolean", () => {
				it( "Can get the default value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getBoolean() ).toBe( false );
				} );
				it( "can set value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setBoolean( true );
					expect( sink.getBoolean() ).toBe( true );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getBoolean() ).toBe( true );
				} );
			} );
			describe( "+date", () => {
				it( "Can get the default value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getDate() ).toBe( "2023-07-29" );
					expect( dateCompare( sink.getDate(), now() ) ).toBe( -1 );
				} );
				it( "can set value", () => {
					var currentTime = now();
					var sink        = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setDate( currentTime );
					expect( sink.getDate() ).toBe( currentTime );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getDate() ).toBe( dateFormat( currentTime, "YYYY-mm-dd" ) );
					expect( dateCompare( loadedSink.getDate(), currentTime ) ).toBe( -1 );
				} );
			} );
			describe( "+datetime", () => {
				it( "Can get the default value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getDatetime() ).toBe( "2023-07-29T04:56" );
					expect( dateCompare( sink.getDatetime(), createDateTime( 2023, 7, 29, 4, 56 ) ) ).toBe( 0 );
				} );
				it( "can set value", () => {
					var theVal = now();
					var sink   = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setDatetime( theVal );
					expect( sink.getDatetime() ).toBe( theVal );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getDatetime() ).toBe( theVal );
				} );
			} );
			describe( "+integer", () => {
				it( "Can get the default value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getInteger() ).toBe( 12303 );
				} );
				it( "can set value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setInteger( 99901 );
					expect( sink.getInteger() ).toBe( 99901 );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getInteger() ).toBe( 99901 );
				} );
			} );
			describe( "+int", () => {
				it( "Can get the default value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getInt() ).toBe( 12404 );
				} );
				it( "can set value", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					sink.setInt( 88808 );
					expect( sink.getInt() ).toBe( 88808 );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getInt() ).toBe( 88808 );
				} );
			} );

			/**
			 * @TODO: Implement these (list from https://cfdocs.org/cfproperty):
			 * @TODO: Identify any missing types from the above list, based on HibernateCaster.java.
			 */
			xdescribe( "+character", () => {
			} );
			xdescribe( "+char", () => {
			} );
			xdescribe( "+short", () => {
			} );
			xdescribe( "+long", () => {
			} );
			xdescribe( "+big_decimal", () => {
			} );
			xdescribe( "+float", () => {
			} );
			xdescribe( "+double", () => {
			} );
			xdescribe( "+yes_no", () => {
			} );
			xdescribe( "+true_false", () => {
			} );
			xdescribe( "+text", () => {
			} );
			xdescribe( "+timestamp", () => {
			} );
			xdescribe( "+binary", () => {
			} );
			xdescribe( "+serializable", () => {
			} );
			xdescribe( "+blob", () => {
			} );
			xdescribe( "+clob", () => {
			} );
		} );

		describe( "insert/update constraints", () => {
			describe( "insert=false", () => {
				it( "inserts null", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getNoInsert() ).toBe( "thedefault" );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getNoInsert() ).toBeNull();
				} );
				it( "can update", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getNoInsert() ).toBe( "thedefault" );
					entitySave( sink );
					ormFlush();
					sink.setNoInsert( "valuetoinsert" );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getNoInsert() ).toBe( "valuetoinsert" );
				} );
			} );
			describe( "update=false", () => {
				it( "can insert", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getNoUpdate() ).toBe( "thedefault" );
					sink.setNoUpdate( "valuetoinsert" );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getNoUpdate() ).toBe( "valuetoinsert" );
				} );
				it( "will not update", () => {
					var sink = entityNew( "KitchenSink", { id : createUUID() } );
					expect( sink.getNoUpdate() ).toBe( "thedefault" );
					entitySave( sink );
					ormFlush();
					sink.setNoUpdate( "valuetoupdate" );
					entitySave( sink );
					ormFlush();
					ormClearSession();
					var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
					expect( loadedSink.getNoUpdate() ).toBe( "thedefault" );
				} );
			} );
		} );
	}

}
