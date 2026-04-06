component {
	this.name = "test-entityCache-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-entityCache" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		secondaryCacheEnabled: true,
		cacheProvider: "ehcache",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
