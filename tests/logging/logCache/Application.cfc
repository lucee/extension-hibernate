component {

	this.name = "orm-logCache-#url.logCache ?: false#-#hash( getCurrentTemplatePath() )#";
	this.datasources["h2"] = server.getDatasource( "h2", server._getTempDir( "orm-logCache" ) );
	this.datasource = "h2";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		logSQL: false,
		logCache: url.logCache ?: false,
		secondarycacheenabled: true,
		cacheprovider: "ehcache",
		cacheconfig: getDirectoryFromPath( getCurrentTemplatePath() ) & "ehcache.xml"
	};

	function onRequestStart() {
		ormReload();
	}

}
