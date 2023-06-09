component {

	this.name 				= "orm" & hash( getCurrentTemplatePath() );
	
	this.mappings[ "testsRoot" ] = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers = new tests.specs.luceeTests.TestHelper();
	this.datasource= server.helpers.getDatasource("h2", expandPath( "./db/orm-many2one") );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate = "dropcreate"
	};


	public function onRequestStart() {
		setting requesttimeout=10;
	}

}