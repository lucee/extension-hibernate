component {

	
	this.mappings[ "testsRoot" ] = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers = new tests.specs.luceeTests.TestHelper();
	this.datasources.test = server.helpers.getDatasource( "h2", expandPath("db") );

	this.name = "LDEV0423";
	this.datasource = "test";
	this.ormEnabled = true;
	this.ormSettings = {
    	dbcreate: "dropcreate",
      	logSQL=true
   	};
	
	public function onRequestStart() {
		setting requesttimeout=10;
	}
}
