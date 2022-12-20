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
		local.events = deserializeJson(result.fileContent);
		systemOutput( events, true );
		expect( events.len() ).toBe( 20 );
		// expect( trim( result.fileContent ) ).toBe( arrExpectedEvents ); // TODO this should be an array of event names
		/*
		i.e. arrExpectedEvents to be something like this
		["preInsert","preInsert","postInsert","postInsert","preInsert","preInsert","preLoad","preLoad","postLoad","postLoad","postInsert","postInsert","postUpdate","postUpdate","preDelete","preDelete","postDelete","postDelete"] */
	}

	private string function createURI(string calledName){
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
} 
</cfscript>