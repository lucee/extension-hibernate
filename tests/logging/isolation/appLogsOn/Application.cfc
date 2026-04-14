component {

	this.name = "orm-isolation-logson-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-isolation-on" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		logSQL: true,
		logParams: true
	};

	function onRequestStart() {
		ormReload();
	}

}
