component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {
		describe("ORM Savepoint Support",  function() {
			// LDEV-3657: ORMConnection.setSavepoint() throws "this feature is not supported"
			it( title="can use transaction savepoint", skip=true, body=function( currentSpec ) {
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