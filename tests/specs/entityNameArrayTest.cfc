component extends="testbox.system.BaseSpec" {

    public void function run(){
        describe( "entityNameArray()", () => {
            it( "will return known entity names", () => {

                expect( entityNameArray() ).toBeArray()
                    .toHaveLength( 4 )
                    .toInclude( "Auto" )
                    .toInclude( "Dealership" )
                    .toInclude( "User" );
            });
        });
    }
}