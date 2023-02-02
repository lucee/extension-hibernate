<cfscript>
    /**
     * TODO: Verify that the hibernate config is loaded and in effect.
     */
    transaction{
        car = entityNew( "Auto" );
        car.setId( createUUID() );
        car.setMake( "Ford" );
        entitySave( car );
        ormFlush();
    }

    // Delete the item from the DB
    queryExecute( "DELETE FROM Auto WHERE id=:id", { id : car.getId() }, { datasource : "h2" } );

    // don't let Hibernate load from the first-level cache( the session )
    ormClearSession();

    // test that it loads from the cache.
    otherCar = entityLoad( "Auto", car.getId() );
    if ( isNull( otherCar ) ){
        throw( "Car #car.getId()# not found in 2nd-level cache!" );
    }
</cfscript>