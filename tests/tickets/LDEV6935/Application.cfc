component {
	this.name = "LDEV-6935";
	this.datasources["ldev6935"] = server.getDatasource( "h2", server._getTempDir( "LDEV6935" ) );
	this.datasource = "ldev6935";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2",
		flushAtRequestEnd: false
	};
}
