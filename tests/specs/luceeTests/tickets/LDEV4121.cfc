component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm"{
	function beforeAll() {
		variables.uri = server.helpers.getTestPath("tickets/LDEV4121");
	}

	function afterAll() {
		cleanup();
	}

	private function cleanUp() {
		if (!notHasH2()) {
			queryExecute( sql="DROP TABLE IF EXISTS LDEV4121", options: {
				datasource: server.helpers.getDatasource("h2", variables.dbfile)
			}); 
		}
	}

	function run( testResults, testBox ) {
		// TODO: Skipped until fixed.
		xdescribe(title="Testcase for LDEV-4121", body=function() {
			it( title="checking default property value to override NULL value on ORM Entity",skip=!!server.helpers.isValidDatasource( "h2" ),   body=function( currentSpec ){
				local.result = _InternalRequest(
					template : "#uri#\LDEV4121.cfm"
				);
				expect(trim(result.filecontent)).toBe("default organization name");
			});
		});
	}

}