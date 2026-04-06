component {
	this.name = "test-lazyAfterClose-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-lazyAfterClose" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		flushAtRequestEnd: false,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
