<cfscript>
    ormReload();
    transaction{
        myEntity = entityNew( "Auto", {
            "make" : "Hyundai",
            "model" : "Accent",
            "id" : createUUID()
        } );
    
        entitySave( myEntity );
        transactionSetSavepoint(); // throws "This feature not supported".
    }
</cfscript>