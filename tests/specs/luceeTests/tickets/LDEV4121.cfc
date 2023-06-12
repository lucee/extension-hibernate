component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm"{

	function run( testResults, testBox ) {
		// TODO: Fix Me!
		// https://luceeserver.atlassian.net/browse/LDEV-4121
		var isResolved = FALSE;

		describe(title="Testcase for LDEV-4121", body=function() {
			it( "checking default property value to override NULL value on ORM Entity", function( currentSpec ){
				local.result = _InternalRequest(
					template : server.helpers.getTestPath("tickets/LDEV4121") & "\LDEV4121.cfm"
				);
				expect(trim(result.filecontent)).toBe("default organization name");
			});
		}, skip = !isResolved);
	}

}