component extends="testbox.system.BaseSpec" {

    public void function run(){
        describe( "entityNameArray()", () => {
            it( "will return known entity names", () => {

                expect( entityNameArray() ).toBeArray()
                    .toInclude( "Auto" )
                    .toInclude( "Dealership" )
                    .toInclude( "User" );
            });
        });
    }
}