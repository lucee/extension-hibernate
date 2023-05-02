component extends="testbox.system.BaseSpec" {

    public void function run(){
        expect( entityNameList() ).toBe( "Auto,User,Dealership" );
        expect( entityNameList( "|" ) ).toBe( "Auto|User|Dealership" );
    }
}