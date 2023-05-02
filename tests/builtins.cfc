component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

    public void function testBuiltins(){

        local.uri=createURI("builtins/index.cfm");
        local.result=_InternalRequest(uri);
        expect( result.status ).toBe( 200 );
    }

	private string function createURI(string calledName){
		systemOutput("", true);
		systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
}