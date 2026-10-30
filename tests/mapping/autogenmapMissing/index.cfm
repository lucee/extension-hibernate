<cfscript>
    test = new test();
    test.setName( "testing" );
    entitySave( test );
    result = entityLoadByPK( "test", test.getId() );
    echo( result.getName() );
</cfscript>
