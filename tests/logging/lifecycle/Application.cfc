component {

	this.name = "orm-lifecycle-#url.appId ?: hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-lifecycle" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		logSQL: url.logSQL ?: false,
		logParams: url.logParams ?: false,
		logCache: url.logCache ?: false,
		logVerbose: url.logVerbose ?: false
	};

}
