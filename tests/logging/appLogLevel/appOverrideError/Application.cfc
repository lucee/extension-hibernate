component {

	this.name = "orm-applog-error-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-applog-error" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		logSQL: true,
		logParams: true
	};

	// Application-level log override — set orm log to ERROR
	this.logs = {
		"orm": {
			"appender": "resource",
			"appenderArguments": {
				"path": "{lucee-config}/logs/orm.log"
			},
			"level": "error",
			"layout": "classic"
		}
	};

	function onRequestStart() {
		ormReload();
	}

}
