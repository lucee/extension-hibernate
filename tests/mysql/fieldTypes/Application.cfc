component {
	this.name = "test-fieldTypes-mysql-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "mysql" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
