component {
	this.name = "LDEV-2859";
	this.datasources["ldev2859"] = server.getDatasource( "h2", server._getTempDir( "LDEV2859" ) );
	this.datasource = "ldev2859";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2"
	};
}
