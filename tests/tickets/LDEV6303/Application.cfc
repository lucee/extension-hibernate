component {
	this.name = "LDEV-6303";
	this.datasources["ldev6303"] = server.getDatasource( "h2", server._getTempDir( "LDEV6303" ) );
	this.datasource = "ldev6303";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2"
	};
}
