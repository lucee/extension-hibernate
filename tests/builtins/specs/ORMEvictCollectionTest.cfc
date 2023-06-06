component extends="testbox.system.BaseSpec" {

    public void function run(){
        transaction{
            expect( () => {
                ormEvictCollection( "Auto", "inventory" );
            }).notToThrow();

            expect( () => {
                ormEvictCollection( "Auto", "inventory", "12345" );
            }).notToThrow();
        }
    }
}