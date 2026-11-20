component {
	this.name = "LDEV-6941-" & ( url.autoManage ?: true );
	this.datasources["ldev6941"] = server.getDatasource( "h2", server._getTempDir( "LDEV6941" ) );
	this.datasource = "ldev6941";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2",
		flushAtRequestEnd: false,
		autoManageSession: ( url.autoManage ?: true )
	};
}
