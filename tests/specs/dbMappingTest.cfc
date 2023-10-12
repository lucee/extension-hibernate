component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "useDBForMapping", () => {
			beforeEach( () => {
				var result            = _internalRequest( "/tests/testApp/index.cfm?reinitApp=true" );
				variables.ormSettings = {
					dbcreate  : "update",
					useDbForMapping : true
				};
			} );

			it( title = "Can read table column data from the database", body = () => {
                var randomPropertyName = "Name_#randRange(0,9999999)#";
                var randomVarcharLen   = randRange(0,8000);
                var randomDefault      = "default_#randRange( 0, 99999 )#";

				var theTest = () => {
                    queryExecute( "ALTER TABLE KitchenSink ADD #randomPropertyName# VARCHAR(#randomVarcharLen#) DEFAULT '#randomDefault#' NULL", {}, { "datasource" : "mysql" } );
					ormReload();
				};
				var result = _internalRequest(
					template: "/tests/testApp/index.cfm",
					forms   : {
						ormSettings : serializeJSON( variables.ormSettings ),
						closure     : serialize( theTest )
					}
				);

                cfdbinfo( type="Columns", name="result", table="KitchenSink", datasource="mysql" );

                var exists = result.filter( ( row ) => row.COLUMN_NAME == randomPropertyName );
                expect( exists.recordCount ).toBe( 1 );

                var row = exists.first();
                expect( exists.TYPE_NAME[1] ).toBe( "VARCHAR" );
                expect( exists.COLUMN_SIZE[1] ).toBe( randomVarcharLen );
                expect( exists.COLUMN_DEFAULT_VALUE[1] ).toBe( randomDefault );

			}, skip= !server.helpers.canUseDatasource( "mysql" ) );
		} )
	}

}
