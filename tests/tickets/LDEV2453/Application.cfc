component {
	this.name = "LDEV-2453";
	this.datasources["ldev2453"] = server.getDatasource( "h2", server._getTempDir( "LDEV2453" ) );
	this.datasource = "ldev2453";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2"
	};
}
