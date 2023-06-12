component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm"{
	public function run( testResults , testBox ) {
		describe( title = "Testing date functions & its equivalent member functions for ORM entity's date", body = function() {
			it( "Testing dateDiff function", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				// Dummy request
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene:1
					}
				);

				assertEquals("", result.fileContent.trim());
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 1,
						Purpose: "dateDiff"
					}
				);
				assertEquals("4", result.fileContent.trim());
			});

			it( "Testing dateDiff's equivalent member function", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 1,
						Purpose: "dateDiffMember"
					}
				);
				assertEquals("-4", result.fileContent.trim());
			});

			it( "Testing dateDiff function with formatted date", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 2,
						Purpose: "dateDiff"
					}
				);
				assertEquals("4", result.fileContent.trim());
			});

			it( "Testing dateDiff's equivalent member function function with formatted date", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 2,
						Purpose: "dateDiffMember"
					}
				);
				assertEquals("-4", result.fileContent.trim());
			});

			it( "Testing dateCompare function", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 1,
						Purpose: "dateCompare"
					}
				);
				assertEquals("-1", result.fileContent.trim());
			});

			it( "Testing dateCompare's equivalent member function", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 1,
						Purpose: "dateCompareMember"
					}
				);
				assertEquals("-1", result.fileContent.trim());
			});

			it( "Testing dateCompare function with formatted date", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 2,
						Purpose: "dateCompare"
					}
				);
				assertEquals("-1", result.fileContent.trim());
			});

			it( "Testing dateCompare's equivalent member function with formatted date", function( currentSpec ) {
				var uri = server.helpers.getTestPath("tickets/LDEV0374/test.cfm");
				var result = _InternalRequest(
					template:uri,
					forms:{
						Scene: 2,
						Purpose: "dateCompareMember"
					}
				);
				assertEquals("-1", result.fileContent.trim());
			});
		});
	}
}