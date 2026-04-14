component {

	this.name = "orm-isolation-logsoff-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-isolation-off" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		logSQL: false,
		logParams: false
	};

	function onRequestStart() {
		ormReload();
	}

}
