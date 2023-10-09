component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "entityLoad()", () => {

            /**
             * TODO: Skip until fixed.
             * https://luceeserver.atlassian.net/browse/LDEV-4285
             */
            describe( "LDEV-4285 - Positional and named arguments testcase", function(){
                it( "entityLoad() with positional argument(name)", () =>{
                        expect( isArray( entityLoad("Auto") ) ).toBe( true );
                } );
                it( "entityLoad() with positional arguments(name, idOrFilter)", () =>{
                        expect( isArray(entityLoad("Auto", {})) ).toBe( true );
                } );
                it( "entityLoad() with positional arguments(name, idOrFilter, uniqueOrOrder)", () =>{
                        expect( isArray(entityLoad("Auto", {}, "")) ).toBe( true );
                } );
                it( "entityLoad() with positional arguments(name, idOrFilter, uniqueOrOrder, options)", () =>{
                        expect( isArray(entityLoad("Auto", {}, "", {})) ).toBe( true );
                } );
                it( "entityLoad() with named arguments(name, idOrFilter, uniqueOrOrder, options)", () =>{
                        expect( isArray(entityLoad(name="Auto", id={}, unique="", options={})) ).toBe( true );
                } );
                it( "entityLoad() with named arguments(name, idOrFilter, options)", () =>{
                        expect( isArray(entityLoad(name="Auto", id={}, options={})) ).toBe( true );
                } );
                it( "entityLoad() with named arguments(name, idOrFilter)", () =>{
                        expect( isArray(entityLoad(name="Auto", id={})) ).toBe( true );
                } );
                xit( "entityLoad() with named arguments(name, options)", () =>{
                        expect( isArray(entityLoad(name="Auto", options={})) ).toBe( true );
                } );
                xit( "entityLoad() with named arguments(name, uniqueOrOrder)", () =>{
                        expect( isArray(entityLoad(name="Auto", unique="")) ).toBe( true );
                } );
                it( "entityLoad() with named arguments(name, idOrFilter, uniqueOrOrder)", () =>{
                        expect( isArray(entityLoad(name="Auto", id={}, unique="")) ).toBe( true );
                    }
                );
            } );
		} );
	}

}
