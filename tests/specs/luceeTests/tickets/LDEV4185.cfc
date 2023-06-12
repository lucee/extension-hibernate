component extends="org.lucee.cfml.test.LuceeTestCase" labels="ORM" {

	function beforeAll(){
		variables.uri = server.helpers.getTestPath( "tickets/LDEV4185" );
	}

	function run( testResults, testBox ){
		// TODO: Skip until fixed.
		xdescribe( "Testcase for LDEV4185", function(){
			it(
				title = "Checking isWithinTransaction() with native Hibernate transaction",
				skip  = !!server.helpers.isValidDatasource( "h2" ),
				body  = function( currentSpec ){
					var result = _InternalRequest( template: "#variables.uri#/LDEV4185.cfm" );
					expect( trim( result.filecontent ) ).toBeTrue();
				}
			);
		} );
	}

}
