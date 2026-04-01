component {
	this.name = "test-schemaMode-mssql-#url.dbcreate ?: 'dropcreate'#-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "mssql" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: url.dbcreate ?: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
