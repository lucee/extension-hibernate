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
		local.expectedEvents =  [ "onFlush", "preLoad", "postLoad", "preLoad", "postLoad", "onDelete", "onFlush", "preInsert", "postInsert", "preUpdate", "postUpdate", "preDelete", "postDelete", "onClear" ];
		expect( res.events ).toBe( expectedEvents );
		expect( res.errors.len() ).toBe( 0, "errors" );
	}

	public void function testEvents_createNew (){
		systemOutput( "", true );
		local.uri=createURI("events/createNew.cfm");
		local.result=_InternalRequest(uri);
		expect( result.status ).toBe( 200 );
		local.res = deserializeJson(result.fileContent);
		systemOutput( res.events, true );
		if (len(res.errors)){
			loop array=res.errors, item="local.err"{
				systemOutput("ERROR: " & err.error, true, true);
			}
		}
		local.expectedEvents =  [ "onFlush", "preInsert", "postInsert", "onClear" ];
		expect( res.events ).toBe( expectedEvents ); 
		expect( res.errors.len() ).toBe( 0, "errors" );
	}

	public void function testEvents_load (){
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
		local.expectedEvents =  [ "onFlush", "preInsert", "postInsert", "onClear", "preLoad", "postLoad" ];
		expect( res.events ).toBe( expectedEvents ); 
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