component {

	this.name        = hash( getCurrentTemplatePath() );
	this.ormEnabled  = "true";
	this.ormSettings = {
		dbcreate    : "update",
		cfcLocation : "orm",
		savemapping : true
	};


	this.mappings[ "testsRoot" ]     = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers                   = new tests.specs.luceeTests.TestHelper();
	this.datasource                  = server.helpers.getDatasource( "h2", expandPath( "./db/jira3049" ) );

	public function onRequestStart(){
		setting requesttimeout=10;
	}

}
