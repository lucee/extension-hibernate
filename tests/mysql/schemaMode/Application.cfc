component {
	this.name = "test-schemaMode-mysql-#url.dbcreate ?: 'dropcreate'#-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "mysql" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: url.dbcreate ?: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
