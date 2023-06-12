component {

	this.name = "LDEV1428" & hash( getCurrentTemplatePath() );


	this.mappings[ "testsRoot" ]     = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers                   = new tests.specs.luceeTests.TestHelper();
	this.datasource                  = server.helpers.getDatasource( "h2", expandPath( "./db/LDEV1428" ) );

	this.ormEnabled  = true;
	this.ormSettings = {
		savemapping           : true,
		dbcreate              : "update",
		secondarycacheenabled : false,
		logSQL                : true,
		flushAtRequestEnd     : false,
		autoManageSession     : false,
		skipCFCWithError      : false
	};

	public function onRequestStart(){
		setting requesttimeout=10;
	}

}
