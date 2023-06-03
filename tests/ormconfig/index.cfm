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
</cfscript>