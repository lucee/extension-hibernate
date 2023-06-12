component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ){
		describe(
			title = "Test suite for LDEV-1984",
			body  = function(){
				it(
					title = "checking ORMEvictEntity() without secondary Cache ",
					body  = function( currentSpec ){
						var uri    = server.helpers.getTestPath( "tickets/LDEV1984" );
						var result = _InternalRequest(
							template: "#uri#/App1/index.cfm",
							urls    : { appName : "AppOne" }
						);

						assertEquals( 200, result.status_code );

						if ( result.status_code == 200 ) assertEquals( "Bar", result.filecontent.trim() );
					}
				);

				it(
					title = "checking ORMEvictEntity() with secondary Cache",
					body  = function( currentSpec ){
						var uri    = server.helpers.getTestPath( "tickets/LDEV1984" );
						var result = _InternalRequest(
							template: "#uri#/App1/index.cfm",
							urls    : { appName : "AppTwo" }
						);

						assertEquals( 200, result.status_code );
						if ( result.status_code == 200 ) assertEquals( "Bar", result.filecontent.trim() );
					}
				);
			}
		);
	}

	// private Function//

}
