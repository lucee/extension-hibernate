component extends="testbox.system.BaseSpec" {

    public void function run(){

        transaction {
            EntitySave( 
                entityNew( "Auto", { make : "Ford", id : createUUID() } ) 
            );
        }

        // inline parameter
        result = ormExecuteQuery(
            hql:"SELECT id FROM Auto WHERE make = 'Ford'",
            unique:true
        );
        expect(isValid("uuid",result)).toBe(true);

        // struct parameter
        result = ormExecuteQuery(
            "SELECT id FROM Auto WHERE make = :make",
            {make:"Ford" } ,
            true
        );
        expect(isValid("uuid",result)).toBe(true);

        // array parameter
        result = ormExecuteQuery(
            "SELECT id FROM Auto WHERE  make = ?1",
            [ "Ford" ],
            true
        );
        expect(isValid("uuid",result)).toBe(true);

        // legacy parameter
        result = ormExecuteQuery(
            "SELECT id FROM Auto WHERE  make = ?",
            [ "Ford" ],
            true
        );
        expect(isValid("uuid",result)).toBe(true);

        expect(
            ormExecuteQuery( "
                select count(id)
                from Auto
                WHERE make = :make
            ", { make : "Ford" }, false, { cacheable: false } )
        ).toBeArray().toHaveLength(1);

        expect(
            ormExecuteQuery( "
                select count(id)
                from Auto
                WHERE make = :make
            ", { make : "Ford" }, true )
        ).toBeNumeric( 1 ).toBe( 1 );

        expect(
            ormExecuteQuery( "
                select count(id)
                from Auto
                WHERE make = :make
            ", { make : "Ford" }, true, { cacheable: false } )
        ).toBeNumeric( 1 ).toBe( 1 );
    }
}