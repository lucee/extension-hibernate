component {
	this.name = "LDEV-2121";
	this.datasources["ldev2121"] = server.getDatasource( "h2", server._getTempDir( "LDEV2121" ) );
	this.datasource = "ldev2121";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2",
		secondaryCacheEnabled: true,
		cacheProvider: "ehcache"
	};
}
