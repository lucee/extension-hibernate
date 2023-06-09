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
 ---><cfscript>component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	//public function setUp(){}

	public void function testMany2One() {
		local.uri=server.helpers.getTestPath("orm/many2one/index.cfm");
		local.result=_InternalRequest(uri);
		assertEquals(200,result.status);

		var ref=evaluate(trim(result.fileContent));
		if(isArray(ref))ref=ref[1];

		
		assertTrue(isValid('component',ref));
		assertEquals(1,ref.getId());
		
		var code=ref.getCode();
		assertTrue(isValid('component',code));
		assertEquals(1,code.getId());
		assertEquals("a",code.getCode());
	}

	public void function testMany2Many() {
		local.uri=server.helpers.getTestPath("orm/many2many/index.cfm");
		local.result=_InternalRequest(uri);
		assertEquals(200,result.status);
		assertEquals("moduleLangs:1;2;Tags:1;2;",trim(result.fileContent));
	}

	// ormSettings dialects tests
	public void function testDialectMYSQL() skip="notHasMysql" {
		local.uri=server.helpers.getTestPath("orm/testDialects/testMysql/index.cfm");
		local.result=_InternalRequest(uri);
		assertEquals(200,result.status);
		assertEquals(true, findNoCase("mysql", result.fileContent) > 0);
	}

	public void function testDialectMSSQL() skip="notHasMSSQL" {
		local.uri=server.helpers.getTestPath("orm/testDialects/testMssql/index.cfm");
		local.result=_InternalRequest(uri);
		assertEquals(200,result.status);
		assertEquals(true, findNoCase("SQLServer", result.fileContent) > 0);
	}

	public void function testDialectPostgres() skip="notHasPostgres" {
		local.uri=server.helpers.getTestPath("orm/testDialects/testPostgres/index.cfm");
		local.result=_InternalRequest(uri);
		assertEquals(200,result.status);
		assertEquals(true, findNoCase("postgres", result.fileContent) > 0);
	}
	
	public void function testDialectH2() {
		local.uri=server.helpers.getTestPath("orm/testDialects/testH2/index.cfm");
		local.result=_InternalRequest(uri);
		assertEquals(200,result.status);
		assertEquals(true, findNoCase("H2", result.fileContent) > 0);
	}


	public boolean function notHasMysql() {
		return structCount(server.helpers.getDatasource("mysql")) == 0;
	}

	public boolean function notHasMSSQL() {
		return structCount(server.helpers.getDatasource("mssql")) == 0;
	}

	public boolean function notHasPostgres() {
		return structCount(server.helpers.getDatasource("postgres")) == 0;
	}

	public boolean function isHibernate54() {
		var version = extensionList().filter( function(row){ return row.name contains "hibernate" }).version;
		return left(version,3) eq "5.4";
	}
} 
</cfscript>