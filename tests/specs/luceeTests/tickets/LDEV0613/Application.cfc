component {
	this.name = hash( getCurrentTemplatePath() );
	


	
	this.mappings[ "testsRoot" ] = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers = new tests.specs.luceeTests.TestHelper();
 	this.datasource = server.helpers.getDatasource( "h2", expandPath("db") );

	this.ormEnabled = true;
	this.ormSettings = {
		savemapping=true,
		dbcreate = 'dropcreate',
		logSQL=true
	};
	
	public function onRequestStart() {
		setting requesttimeout=10;
	}

}