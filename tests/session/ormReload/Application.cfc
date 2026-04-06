component {
	this.name = "test-ormReload-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-ormReload" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		flushAtRequestEnd: false,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
