component {
	this.name = "LDEV-717";
	this.datasources["ldev717"] = server.getDatasource( "h2", server._getTempDir( "LDEV717" ) );
	this.datasource = "ldev717";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2"
	};
}
