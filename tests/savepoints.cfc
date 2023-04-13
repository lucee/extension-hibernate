component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {
		describe("ORM Savepoint Support",  function() {
			it( title="can use transaction savepoint", skip="true"  body=function( currentSpec ) {
                local.uri=createURI("savepoints/index.cfm");
                local.result=_InternalRequest(uri);
                expect( result.status ).toBe( 200 );
			});
		});
	}

	private string function createURI(string calledName){
		systemOutput("", true);
		systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
}