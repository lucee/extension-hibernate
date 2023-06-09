component {
	this.name 				= "LDEV1370" & hash( getCurrentTemplatePath() );

	
	this.mappings[ "testsRoot" ] = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers = new tests.specs.luceeTests.TestHelper();
	this.datasource = server.helpers.getDatasource("h2",expandPath( "./db/LDEV1370") );

	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate = "update",
		secondarycacheenabled = false,
		//flushAtRequestEnd 	= true,
		//autoManageSession	= true,
		secondaryCacheEnabled = false,
		eventhandling = true
	};

	if(!isNull(url.flushAtRequestEnd)) this.ormSettings.flushAtRequestEnd=url.flushAtRequestEnd;
	if(!isNull(url.autoManageSession)) this.ormSettings.autoManageSession=url.autoManageSession;
	
	public function onRequestStart() {
		setting requesttimeout=10;
	}
}