component{
	this.name = hash(getCurrentTemplatePath()) & getTickCount();
	
	this.mappings[ "testsRoot" ] = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers = new tests.specs.luceeTests.TestHelper();
 	this.datasources.test = server.helpers.getDatasource("h2", expandPath( "./db/orm-many2many") );
	this.datasource = 'test'; 
		
	this.ormEnabled = true; 
	this.ormSettings = { 
		dbcreate = 'dropcreate',
		saveMapping=true,
		cfclocation = 'model'
	} ;
	function onRequestStart(){
		setting requesttimeout=10;
	}
}