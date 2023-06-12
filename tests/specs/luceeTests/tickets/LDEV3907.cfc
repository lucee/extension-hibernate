component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll(){
		variables.uri = server.helpers.getTestPath( "tickets/LDEV3907" );
	}

	function run( testResults, testBox ){
		// TODO: Skipped until fixed.
		xdescribe( "Testcase for LDEV-3907", function(){
			it(
				title = "Setting the default value in the primary key in ORM entity",
				body  = function( currentSpec ){
					try {
						local.result = _InternalRequest( template: "#uri#\LDEV3907.cfm" ).filecontent;
					} catch ( any e ) {
						result = e.message;
					}
					expect( trim( result ) ).toBe( "LDEV3907" );
				}
			);
		} );
	}

}
