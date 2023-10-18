component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "entityNew()", () => {
			it( "returns an entity", () => {
				expect( entityNew( "Auto" ) )
                    .toBeComponent()
                    .toBeInstanceOf( "Auto" );
			} );

			it( "can populate an entity", () => {
                var myCar = entityNew( "Auto", {
                    make : "Ford",
                    model : "Fusion"
                } );
				expect( myCar ).toBeComponent();
                expect( myCar.getMake() ).toBe( "Ford" );
                expect( myCar.getModel() ).toBe( "Fusion" );
			} );

			it( "will throw on undefined properties", () => {
                expect(() => {
                    var myCar = entityNew( "Auto", {
                        make : "Ford",
                        model : "Fusion",
                        propThatDoesntExist : "abc"
                    } );

                /**
                 *  @TODO: in future extension versions, it would be cool if we threw a targeted exception type
                 *  like `PropertyNotFoundException` or something.
                 */
                }).toThrow();
			} );

			it( "will not throw on a defined, non-persistent property", () => {
                var myCar = entityNew( "Auto", {
                    make : "Ford",
                    model : "Fusion",
                    nonPersistentProp : "abc"
                } );
                expect( myCar.getNonPersistentProp() ).toBe( "abc" );
			} );
            
		} );
	}

}