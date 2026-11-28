component {
	this.name = "LDEV-7026-" & ( url.autoManage ?: true );
	this.datasources["ldev7026"] = server.getDatasource( "h2", server._getTempDir( "LDEV7026" ) );
	this.datasource = "ldev7026";
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2",
		flushAtRequestEnd: false,
		autoManageSession: ( url.autoManage ?: true )
	};
}
