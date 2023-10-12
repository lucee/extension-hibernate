component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll(){
		variables.uri = server.helpers.getTestPath( "tickets/LDEV2862" );
	}
	function run( testResults, testBox ){
		// TODO: Fix Me!
		// https://luceeserver.atlassian.net/browse/LDEV-2862
		var isResolved = FALSE;
		describe( title = "Testcase for LDEV-2862", body = () => {
			it( "Duplicate() with the ORM entity which has relationship mappings", () => {
					local.result = _InternalRequest( template: "#uri#\test.cfm" );
					expect( trim( result.fileContent ) ).toBe( "success" );
				}
			);
		}, skip = !isResolved );
	}

}
