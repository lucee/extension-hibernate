/**
 * This test is intended to test a all supported field types.
 */
component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "Field Types", () => {
            describe( "+timezone", () => {
                it( "Can get the default value", () => {
                    var sink = entityNew( "KitchenSink",{
                        id : createUUID()
                    });
                    expect( sink.getTimezone() ).toBe( "America/Los_Angelos" );
                } );
                it( "can set value", () => {
                    var sink = entityNew( "KitchenSink",{
                        id : createUUID()
                    });
                    sink.setTimeZone( "Pacific/Midway");
                    expect( sink.getTimeZone() ).toBe( "Pacific/Midway" );
                    entitySave( sink );
                    ormFlush();
                    ormClearSession();
                    var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
                    expect( loadedSink.getTimeZone() ).toBe( "Pacific/Midway" );
                });
            });
            describe( "+string", () => {
                it( "Can get the default value", () => {
                    var sink = entityNew( "KitchenSink",{
                        id : createUUID()
                    });
                    expect( sink.getString() ).toBe( "defaultstringvalue" );
                } );
                it( "can set value", () => {
                    var sink = entityNew( "KitchenSink",{
                        id : createUUID()
                    });
                    sink.setString( "theNewValue");
                    expect( sink.getString() ).toBe( "theNewValue" );
                    entitySave( sink );
                    ormFlush();
                    ormClearSession();
                    var loadedSink = entityLoadByPK( "KitchenSink", sink.getId() );
                    expect( loadedSink.getString() ).toBe( "theNewValue" );
                });
            });

            /**
             * @TODO: Implement these (list from CFDocs):
             * @TODO: Identify any missing types from the above list, based on HibernateCaster.java.
             */
            xdescribe( "+character", () => {});
            xdescribe( "+char", () => {});
            xdescribe( "+short", () => {});
            xdescribe( "+integer", () => {});
            xdescribe( "+int", () => {});
            xdescribe( "+long", () => {});
            xdescribe( "+big_decimal", () => {});
            xdescribe( "+float", () => {});
            xdescribe( "+double", () => {});
            xdescribe( "+boolean", () => {});
            xdescribe( "+yes_no", () => {});
            xdescribe( "+true_false", () => {});
            xdescribe( "+text", () => {});
            xdescribe( "+date", () => {});
            xdescribe( "+datetime", () => {});
            xdescribe( "+timestamp", () => {});
            xdescribe( "+binary", () => {});
            xdescribe( "+serializable", () => {});
            xdescribe( "+blob", () => {});
            xdescribe( "+clob", () => {});
		} );
	}

}
