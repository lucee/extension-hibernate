component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {
    function beforeAll(){
        variables.uri = server.helpers.getTestPath("tickets/LDEV2862");
    }
    function run( testResults, testBox ) {
        // TODO: Skip until fixed
        xdescribe("Testcase for LDEV-2862", function() {
            it( title="Duplicate() with the ORM entity which has relationship mappings", body=function( currentSpec ){
                local.result = _InternalRequest(
                    template : "#uri#\test.cfm"
                );
                expect(trim(result.fileContent)).toBe("success");
            });
        });
    }
}
