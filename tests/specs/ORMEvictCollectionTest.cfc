component extends="testbox.system.BaseSpec" {

    public void function run(){
        describe( "ormExecuteQuery()", () => {
            it( "will return entity names", () => {

                // these are pretty bad/useless tests. :/ 
                transaction{
                    expect( () => {
                        ormEvictCollection( "Auto", "inventory" );
                    }).notToThrow();

                    expect( () => {
                        ormEvictCollection( "Auto", "inventory", "12345" );
                    }).notToThrow();
                }
            });
        });
    }
}