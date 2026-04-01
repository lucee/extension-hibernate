component {
	this.name = "test-relationships-mssql-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "mssql" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
