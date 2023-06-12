component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm"{
	function beforeAll(){
		variables.uri = server.helpers.getTestPath("tickets/LDEV1992");
	}
	function run( testResults , testBox ) {
		// TODO: Fix Me!
		// https://luceeserver.atlassian.net/browse/LDEV-1992
		var isResolved = FALSE;

		describe( title = "Test suite for LDEV-1992", body = function() {
			it( 'Checking ', function( currentSpec ) {
				local.result = _InternalRequest(
					template:"#variables.uri#/test.cfm");
				expect(result.filecontent.trim()).toBe(1);
			} );
		}, skip = !isResolved );
	}
	// function afterAll(){
	// 	variables.adminWeb = new org.lucee.cfml.Administrator("web", request.WebAdminPassword);
	// 	var datasource = adminWeb.getDatasource('TestDSN1');
	// 	if (!StructIsEmpty(datasource)){
	// 		adminWeb.removeDatasource('TestDSN1');
	// 	}
	// }
} 