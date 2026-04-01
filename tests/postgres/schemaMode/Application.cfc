component {
	this.name = "test-schemaMode-postgres-#url.dbcreate ?: 'dropcreate'#-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "postgres" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: url.dbcreate ?: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
