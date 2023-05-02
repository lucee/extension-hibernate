component extends="testbox.system.BaseSpec" {

    public void function run(){
        expect( entityNameList() ).toBeString();

        expect( listToArray( entityNameList(), "," ) )
                    .toHaveLength( 3 )
                    .toInclude( "Auto" )
                    .toInclude( "Dealership" )
                    .toInclude( "User" );

        expect( listToArray( entityNameList( "|" ), "|" ) )
                    .toHaveLength( 3 )
                    .toInclude( "Auto" )
                    .toInclude( "Dealership" )
                    .toInclude( "User" );
    }
}