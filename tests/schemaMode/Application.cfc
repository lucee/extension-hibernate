component {
	this.name = "test-schemaMode-#url.dbcreate ?: 'dropcreate'#-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-schemaMode-#url.dbcreate ?: 'dropcreate'#" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: url.dbcreate ?: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
