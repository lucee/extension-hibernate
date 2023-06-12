component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm"{

	function beforeAll() {
		variables.uri = server.helpers.getTestPath("tickets/LDEV2859");
	}

	function run( testResults , testBox ) {
		// 😭😭😭😭
		// https://luceeserver.atlassian.net/browse/LDEV-2859
		var isResolved = FALSE;

		describe( "test suite for LDEV2859", function() {
			it(title = "Orm entitytoquery without name", body = function( currentSpec ) {
				local.result = _InternalRequest(
					template : "#uri#/LDEV2859.cfm",
					forms :	{ scene=1 }
				);
				expect(trim(result.filecontent)).toBe("lucee");
			});

			it(title = "Orm entitytoquery with entityName", body = function( currentSpec ) {
				local.result = _InternalRequest(
					template : "#uri#/LDEV2859.cfm",
					forms :	{ scene = 2 }
				);
				expect(trim(result.filecontent)).toBe('Lucee');
			});
		}, skip = isResolved);
	}
}