<cfscript>
    directoryList( "specs", false, "name" ).each( ( spec) => {
        // try{
            var start = getTickCount();
            test = new "specs.#listFirst( spec, ".")#"();
            test.run();
            systemOutput( "==> #spec # PASSED (#getTickCount()-start#ms)", true );
        // } catch( any e ){
        //     systemOutput( "==> #spec # FAILED" );
        //     systemOutput( e.message );
        //     systemOutput( e.extendedInfo );
        // }
    });
</cfscript>