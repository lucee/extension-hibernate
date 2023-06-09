<cfscript>
component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {
	

	public void function test() localMode="modern" {
		local.uri=server.helpers.getTestPath("tickets/Jira3049/index.cfm");
		local.result=_InternalRequest(uri);
		
		assertEquals("",trim(result.filecontent));
		assertEquals(200,result.status);
	}

} 
</cfscript>