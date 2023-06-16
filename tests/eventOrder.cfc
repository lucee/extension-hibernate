component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	public void function testEventsTriggerOrder(){

		local.uri=createURI("eventOrder/preInsert.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		systemOutput( res, true );
		
		expect( res.errors.len() ).toBe( 0, "errors #res.errors.toJson()#" );
		expect( res.events.len() ).toBe( 2 );
		expect( res.events ).toBe( [ "cfc_preInsert", "global_preInsert"] );
		expect( res.events[1] ).toBe( "cfc_preInsert" );
		expect( res.events[2] ).toBe( "global_preInsert" );
	}

	private string function createURI(string calledName){
		systemOutput("", true);
		systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
}