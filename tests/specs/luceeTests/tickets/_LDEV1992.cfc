component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm"{
	function beforeAll(){
		variables.uri = server.helpers.getTestPath("tickets/LDEV1992");
	}
	function run( testResults , testBox ) {
		// 😭😭😭😭
		// https://luceeserver.atlassian.net/browse/LDEV-1992
		var isResolved = FALSE;

		describe( "Test suite for LDEV-1992", function() {
			it( title='Checking ', body=function( currentSpec ) {
				local.result = _InternalRequest(
					template:"#variables.uri#/test.cfm");
				expect(result.filecontent.trim()).toBe(1);
			}, isResolved = false );
		});
	}
	// function afterAll(){
	// 	variables.adminWeb = new org.lucee.cfml.Administrator("web", request.WebAdminPassword);
	// 	var datasource = adminWeb.getDatasource('TestDSN1');
	// 	if (!StructIsEmpty(datasource)){
	// 		adminWeb.removeDatasource('TestDSN1');
	// 	}
	// }
} 