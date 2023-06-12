component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ){
		// TODO: Fix Me!
		// https://luceeserver.atlassian.net/browse/LDEV-87
		var isResolved = FALSE;

		describe(
			title = "ORM persistent false for inherited property",
			body  = function(){
				it( "Case 1: This should be run without failures", function( currentSpec ){
					local.result = _InternalRequest(
						template: server.helpers.getTestPath( "tickets/LDEV0087/index.cfm" )
					);
					assertEquals( "", left( result.filecontent.trim(), 100 ) );
				} );
			},
			skip = !isResolved
		);
	}

}
