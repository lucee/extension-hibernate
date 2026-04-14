component {

	this.name = "orm-applog-trace-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-applog-trace" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		logSQL: true,
		logParams: true
	};

	// Application-level log override — set orm log to TRACE
	this.logs = {
		"orm": {
			"appender": "resource",
			"appenderArguments": {
				"path": "{lucee-config}/logs/orm.log"
			},
			"level": "trace",
			"layout": "classic"
		}
	};

	function onRequestStart() {
		ormReload();
	}

}
