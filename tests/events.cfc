<!--- 
 *
 * Copyright (c) 2016, Lucee Assosication Switzerland. All rights reserved.
 * Copyright (c) 2014, the Railo Company LLC. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 	
 ---><cfscript>
component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	//public function setUp(){}
	public void function testEvents(){

		local.uri=createURI("events/index.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}
		local.expectedEvents =  [
			"EventHandler.onFlush",
			"EventHandler.preLoad", "Code.preLoad",
			"EventHandler.postLoad", "Code.postLoad",
			"EventHandler.preLoad", "Code.preLoad",
			"EventHandler.postLoad", "Code.postLoad",
			"EventHandler.onDelete",
			"EventHandler.onFlush",
			"EventHandler.preInsert", "Code.preInsert",
			"EventHandler.postInsert", "Code.postInsert",
			"EventHandler.preUpdate", "Code.preUpdate",
			"EventHandler.postUpdate", "Code.postUpdate",
			"EventHandler.preDelete", "Code.preDelete",
			"EventHandler.postDelete", "Code.postDelete",
			"EventHandler.onClear"
		];
		// much easier to debug a missing event type
		for( var event in local.expectedEvents ){
			expect( res.events ).toInclude( event );
		}
		// ensure events are emitted in correct order
		expect( res.events ).toBe( expectedEvents );
		expect( res.errors.len() ).toBe( 0, "errors" );
	}

	public void function testEvents_createNew (){
		local.uri=createURI("events/createNew.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}
		local.expectedEvents =  [
			"EventHandler.onFlush",
			"EventHandler.preInsert", "Code.preInsert",
			"EventHandler.postInsert", "Code.postInsert",
			"EventHandler.onClear"
		];
		// much easier to debug a missing event type
		for( var event in local.expectedEvents ){
			expect( res.events ).toInclude( event );
		}
		// ensure events are emitted in correct order
		expect( res.events ).toBe( expectedEvents );
		expect( res.errors.len() ).toBe( 0, "errors" );
	}

	public void function testEvents_load (){
		local.uri=createURI("events/load.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}		
		local.expectedEvents =  [
			"EventHandler.onFlush",
			"EventHandler.preInsert", "Code.preInsert",
			"EventHandler.postInsert", "Code.postInsert",
			"EventHandler.onClear",
			"EventHandler.preLoad", "Code.preLoad",
			"EventHandler.postLoad", "Code.postLoad"
		];
		// much easier to debug a missing event type
		for( var event in local.expectedEvents ){
			expect( res.events ).toInclude( event );
		}
		// ensure events are emitted in correct order
		expect( res.errors.len() ).toBe( 0, "errors" );
	}

	private string function createURI(string calledName){
		systemOutput("", true);
		systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
} 
</cfscript>