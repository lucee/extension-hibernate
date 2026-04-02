component {
	this.name = "test-deadlock-mysql-#hash( getCurrentTemplatePath() )#";
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
