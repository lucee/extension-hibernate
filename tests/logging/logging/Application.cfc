component {

	this.name = "orm-logging-#url.logSQL ?: false#-#url.logParams ?: false#-#url.formatSQL ?: false#-#url.logVerbose ?: false#-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-logging" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		logSQL: url.logSQL ?: false,
		logParams: url.logParams ?: false,
		formatSQL: url.formatSQL ?: false,
		logVerbose: url.logVerbose ?: false
	};

	function onRequestStart() {
		ormReload();
	}

}
