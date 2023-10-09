component extends="testbox.system.BaseSpec" {

	function beforeAll(){
		transaction{
			variables.testDealerID = createUUID();
			queryExecute( "
				INSERT INTO Dealership( id, name, address, phone )
				VALUES (
					:id, :name, :address, :phone
				)
			", {
					"id"      : variables.testDealerID,
					"name"    : "Funky Auto",
					"address" : "456 Motor Drive",
					"phone"   : "123-456-7890"
			} );
		}
	}

	public void function run(){
		describe( "entityLoadByPK()", () => {
			it( "Can load existing entity by ID", () => {
				var theEntity = entityLoadByPK( "Dealership", variables.testDealerID );
				expect( isNull( theEntity ) ).tobeFalse();
			} );
			it( "Returns null if ID not found", () => {
				var theEntity = entityLoadByPK( "Dealership", "doesnotexist" );
				expect( isNull( theEntity ) ).toBeTrue();
			} );

			/**
			 * Commented, since Lucee actually throws this error AT COMPILE TIME 
			 * based on the method signature defined in `ormFunctions.fld`. 😢
			 */
			// xit( "Throws FunctionException if arguments invalid", () => {
			// 	expect(() => {
			// 		var theEntity = entityLoadByPK( "Dealership", "doesnotexist", "threeargs" );
			// 	}).toThrow( "FunctionException" );
			// 	expect(() => {
			// 		var theEntity = entityLoadByPK( "Dealership" );
			// 	}).toThrow( "FunctionException" );
			// 	expect(() => {
			// 		var theEntity = entityLoadByPK();
			// 	}).toThrow( "FunctionException" );
			// 	expect(() => {
			// 		var theEntity = entityLoadByPK( "Dealership", { id : "badIdentifierType" } );
			// 	}).toThrow( "FunctionException" );
			// } );

            /**
             * TODO: Skip until fixed.
             * https://luceeserver.atlassian.net/browse/LDEV-4461
             */
			xdescribe( "LDEV-4461 - positional and named arguments testcase", () => {
				it( "checking positional arguments on ORM EntityLoadByPk", ( currentSpec ) => {
					var result = EntityLoadByPk("Dealership", variables.testDealerID);
					expect(result.getName()).tobe( "Funky Auto" );
				});

				it( "checking named arguments on ORM EntityLoadByPk", ( currentSpec ) => {
					var result = EntityLoadByPk(name = "Dealership", id = variables.testDealerID );
					expect(result.getName()).tobe( "Funky Auto" );
				});

				it( "checking positional arguments on ORM EntityLoadByPk with unique", ( currentSpec ) => {
					var result = EntityLoadByPk("Dealership", variables.testDealerID, true );
					expect(result.getName()).tobe( "Funky Auto" );
				});

				it( "checking named arguments on ORM EntityLoadByPk with unique", ( currentSpec ) => {
					var result = EntityLoadByPk(name="Dealership", id=variables.testDealerID, unique=true );
					expect(result.getName()).tobe( "Funky Auto" );
				});
			})
		} );
	}

}
