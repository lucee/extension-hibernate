component extends="org.lucee.cfml.test.LuceeTestCase" labels="ORM" {

	function beforeAll() {
		variables.uri = server.helpers.getTestPath("tickets/LDEV4185");
	}

	function run( testResults, testBox ) {
		// TODO: Skip until fixed.
		xdescribe("Testcase for LDEV4185", function() {
			it( title="Checking isWithinTransaction() with native Hibernate transaction", skip="#notHasH2()#", body=function( currentSpec ) {
				var result = _InternalRequest(
					template : "#variables.uri#/LDEV4185.cfm"
				);
				expect(trim(result.filecontent)).toBeTrue();
			});
		});
	}

	private boolean function notHasH2() {
		return true;
		return !structCount(server.helpers.getDatasource("h2", expandPath( "./db/LDEV4185")) );
	}

	private string function createURI(string calledName) {
		var baseURI = "/test/#listLast(getDirectoryFromPath(getCurrenttemplatepath()),"\/")#/";
		return baseURI&""&calledName;
	}
}