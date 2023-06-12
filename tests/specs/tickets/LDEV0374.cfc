/**
* Tests for LDEV-0374
* https://luceeserver.atlassian.net/browse/LDEV-374
*/
component extends="testbox.system.BaseSpec"{

        function run( testResults, testBox ){

            describe( "LDEV-0374, usage of date member functions on ORM properties", function(){
                beforeEach( () => {
                    var entityID = createUUID();
                    entitySave( entityNew( "User", {
                        id       : entityID,
                        name     : "Michael",
                        username : "michael",
                        password : "hibernateR0cks",
                        createdOn: dateAdd("d", -4, now())
                    }) );
                    ormFlush();
                    variables.testModel = entityLoadByPK( "User", entityID );

                } );
                it( "Can use dateDiff()", function() {
                    var dateCreated = variables.testModel.getCreatedOn();
                    expect( dateDiff("d", dateCreated, now()) ).toBe( 4 );
                });
                it( "Can use date.diff()", function() {
                    var dateCreated = variables.testModel.getCreatedOn();
                    expect( dateCreated.diff( "d", now() ) ).toBe( 4 );
                });
                it( "Can use dateCompare()", function() {
                    var dateCreated = variables.testModel.getCreatedOn();
                    expect( dateCompare(dateCreated, now(), "d") ).toBe( -1 );
                });
                it( "Can use date.compare()", function() {
                    var dateCreated = variables.testModel.getCreatedOn();
                    expect( dateCreated.compare( now(), "d" ) ).toBe( -1 );

                });
            });
        }
    
    }