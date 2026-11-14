component {
	this.name = "jsonFormatMapper";
	this.datasources["jsonfmt"] = server.getDatasource( "h2", server._getTempDir( "jsonFormatMapper" ) );
	this.datasource = "jsonfmt";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2"
	};
}
