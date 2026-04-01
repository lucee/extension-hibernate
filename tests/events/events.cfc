component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	//public function setUp(){}
/*

     [java]    [script]         testEvents
     [java]    [script]         errors [{"error":"entity was null postInsert  index.cfm: 10","eventName":"postInsert","src":"global"},{"error":"entity was null preLoad  index.cfm: 25","eventName":"preLoad","src":"global"},{"error":"entity was null postLoad  index.cfm: 25","eventName":"postLoad","src":"global"},{"error":"entity was null postInsert  index.cfm: 29","eventName":"postInsert","src":"global"},{"error":"entity was null postUpdate  index.cfm: 29","eventName":"postUpdate","src":"global"},{"error":"entity was null preDelete  index.cfm: 29","eventName":"preDelete","src":"global"},{"error":"entity was null postDelete  index.cfm: 29","eventName":"postDelete","src":"global"}]. Expected [0] Actual [7]
     [java]    [script]                 d:\work\lucee-extensions\extension-hibernate\tests\events.cfc:16

*/

	private void function testEvents() {

		local.uri=createURI("events/index.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		// systemOutput( res.events, true );
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}
		expect( res.errors.len() ).toBe( 0, "errors #res.errors.toJson()#" );
		expect( res.events.len() ).toBe( 20, "events" ); // TBC
		// expect( trim( result.fileContent ) ).toBe( arrExpectedEvents ); // TODO this should be an array of event names
		/*
		i.e. arrExpectedEvents to be something like this
		["preInsert","preInsert","postInsert","postInsert","preInsert","preInsert","preLoad","preLoad","postLoad","postLoad","postInsert","postInsert","postUpdate","postUpdate","preDelete","preDelete","postDelete","postDelete"] */
	}

	/* 
	fails

	     [java]    [script]         testEvents_preInsert
     [java]    [script]         Expected [lucee] but received [ralio]
     [java]    [script]                 d:\work\lucee-extensions\extension-hibernate\tests\events.cfc:31
	 */

	private void function testEvents_preInsert(){

		local.uri=createURI("events/preInsert.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		systemOutput( res, true );
		expect( res.person ).toBe( "lucee" );

		
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}
		expect( res.errors.len() ).toBe( 0, "errors #res.errors.toJson()#" );
		expect( res.events.len() ).toBe( 6, "events" ); // "onFlush","preInsert","postInsert","onClear","preLoad","postLoad"
		// expect( trim( result.fileContent ) ).toBe( arrExpectedEvents ); // TODO this should be an array of event names
		/*
		i.e. arrExpectedEvents to be something like this
		["preInsert","preInsert","postInsert","postInsert","preInsert","preInsert","preLoad","preLoad","postLoad","postLoad","postInsert","postInsert","postUpdate","postUpdate","preDelete","preDelete","postDelete","postDelete"] */
	}

	/*

	fails

	[java]    [script]         errors: [{"error":"entity was null postInsert  createNew.cfm: 9","eventName":"postInsert","src":"global"}]. Expected [0] Actual [1]
    [java]    [script]                 d:\work\lucee-extensions\extension-hibernate\tests\events.cfc:64
    [java]    [script]                 d:\work\lucee6\test\_testRunner.cfc:297

	*/
	private void function testEvents_createNew () {
		systemOutput( "", true );
		local.uri=createURI("events/createNew.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		systemOutput( res.events, true );
		/*
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}
		*/
		local.expectedEvents =  [ "onFlush", "preInsert", "preInsert", "postInsert", "postInsert", "onClear" ]; 
		// local.expectedEvents =  [ "preInsert", "postInsert", "onFlush", "onClear" ]; // TBC
		expect( res.events ).toBe( expectedEvents ); 
		expect( res.errors.len() ).toBe( 0, "errors: #res.errors.toJson()#" );
		expect( res.events.len() ).toBe( 4, "events" );
	}

	public void function testEvents_load () {
		systemOutput( "", true );
		local.uri=createURI("events/load.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		systemOutput( res.events, true );
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}
		local.expectedEvents =  [ "onFlush", "onClear" ]; 
		//local.expectedEvents =  [ "preLoad", "postLoad", "onFlush", "onClear" ]; // TBC
		expect( res.events ).toBe( expectedEvents ); 
		expect( res.errors.len() ).toBe( 0, "errors" );
		expect( res.events.len() ).toBe( 2, "events" );
	}

	private string function createURI(string calledName){
		systemOutput("", true);
		systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
}