component {
	this.name = "test-namingStrategies-#url.strategy ?: 'default'#-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-naming-#url.strategy ?: 'default'#" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	if ( url.keyExists( "strategy" ) ) {
		this.ormSettings.namingStrategy = url.strategy;
	}

	function onRequestStart() {
		ormReload();
	}
}
