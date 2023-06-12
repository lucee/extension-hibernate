component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll(){
		variables.uri = server.helpers.getTestPath( "tickets/LDEV2859" );
	}

	function run( testResults, testBox ){
		// TODO: Fix Me!
		// https://luceeserver.atlassian.net/browse/LDEV-2859
		var isResolved = FALSE;

		describe(
			title = "test suite for LDEV2859",
			body  = function(){
				it( "Orm entitytoquery without name", function( currentSpec ){
					local.result = _InternalRequest( template: "#uri#/LDEV2859.cfm", forms: { scene : 1 } );
					expect( trim( result.filecontent ) ).toBe( "lucee" );
				} );

				it( "Orm entitytoquery with entityName", function( currentSpec ){
					local.result = _InternalRequest( template: "#uri#/LDEV2859.cfm", forms: { scene : 2 } );
					expect( trim( result.filecontent ) ).toBe( "Lucee" );
				} );
			},
			skip = !isResolved
		);
	}

}
