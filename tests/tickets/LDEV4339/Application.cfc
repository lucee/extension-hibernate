component {
	this.name = "LDEV-4339";
	this.datasources["ldev4339"] = server.getDatasource( "h2", "#getDirectoryFromPath( getCurrentTemplatePath() )#datasource/db" );
	this.ormEnabled = true;

	param name="url.autoManageSession" default="false";
	param name="url.flushAtRequestEnd" default="false";

	this.ormSettings = {
		dbcreate: "dropcreate",
		datasource: "ldev4339",
		autoManageSession: url.autoManageSession,
		flushAtRequestEnd: url.flushAtRequestEnd
	};
}
