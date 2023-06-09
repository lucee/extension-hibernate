component {
    this.name = "orm" & hash( getCurrentTemplatePath() );
    this.ORMenabled = true;

    this.ormSettings.dbcreate = "dropcreate"; 
    this.ormSettings.dialect = "H2";

	
	this.mappings[ "testsRoot" ] = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers = new tests.specs.luceeTests.TestHelper();
    this.datasources.test = server.helpers.getDatasource( "h2", expandPath("db") );
    this.datasource = 'test'; 

	public function onRequestStart() {
		setting requesttimeout=10;
	}

}