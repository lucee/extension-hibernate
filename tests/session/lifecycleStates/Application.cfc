component {
	this.name = "test-lifecycleStates-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-lifecycleStates" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		flushAtRequestEnd: false,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
