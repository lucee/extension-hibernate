<cfscript>
    transaction{
        car = entityNew( "Auto" );
        car.setId( createUUID() );
        car.setMake( "Ford" );
        car.setModel( "F-150" );
        entitySave( car );

        dealer = entityNew( "Dealership" );
        dealer.setId( createUUID() );
        dealer.setName( "Sedgewick Subaru" );
        entitySave( dealer );

        ormFlush();
    }

    autoResults = queryExecute( "SELECT * FROM Auto WHERE id=:id", { id : car.getId() }, { datasource: "h2" } );
    if ( !autoResults.recordCount ){
        throw( "auto #car.getId()# not found in datasource table" );
    }

    dealerResults = queryExecute( "SELECT * FROM Dealership WHERE id=:id", { id : dealer.getId() }, { datasource: "h2_otherDB" } );
    if ( !dealerResults.recordCount ){
        throw( "Dealership #dealer.getId()# not found in datasource table" );
    }
</cfscript>