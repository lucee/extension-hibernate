component extends="testbox.system.BaseSpec" {

    public void function run(){
        expect( entityNameArray() ).toBeArray()
                                    .toHaveLength( 3 )
                                    .toInclude( "Auto" )
                                    .toInclude( "Dealership" )
                                    .toInclude( "User" );
    }
}