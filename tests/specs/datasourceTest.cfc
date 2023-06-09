component extends="testbox.system.BaseSpec" {

    public void function run(){

        describe( "multiple datasource support", () => {

            describe( "entity datasources", () => {
                it( "should persist employee to HR database", () => {
                    transaction{
                        employee = entityNew( "Employee" );
                        employee.setId( createUUID() );
                        employee.setName( "Sedgewick" );
                        employee.setTitle( "Janitor" );
                        entitySave( employee );
                    
                        dealer = entityNew( "Dealership" );
                        dealer.setId( createUUID() );
                        dealer.setName( "Sedgewick Subaru" );
                        entitySave( dealer );
                    
                        ormFlush();
                    }

                    expect(
                        queryExecute(
                            "SELECT * FROM Employee WHERE id=:id",
                            { id : employee.getId() },
                            { datasource: "h2_HRdb"}
                        ).recordCount
                    ).toBe( 1, "should save Employee to HR db" );

                    expect( () => {
                        queryExecute(
                            "SELECT * FROM Employee WHERE id=:id",
                            { id : employee.getId() },
                            { datasource: "h2"}
                        ).recordCount
                    } ).toThrow( message = "should NOT save Employee to regular db" );

                    expect(
                        queryExecute(
                            "SELECT * FROM Dealership WHERE id=:id",
                            { id : dealer.getId() },
                            { datasource: "h2" }
                        ).recordCount
                    ).toBe( 1, "should save Dealership to regular (h2) db" );
                });
            });
        })
    }
}