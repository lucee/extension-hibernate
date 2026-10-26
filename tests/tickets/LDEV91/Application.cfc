component {
	this.name = "LDEV-91";
	this.datasources["ldev91"] = server.getDatasource( "h2", server._getTempDir( "LDEV91" ) );
	this.datasource = "ldev91";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2"
	};
}
