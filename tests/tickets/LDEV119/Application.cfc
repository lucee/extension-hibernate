component {
	this.name = "LDEV-119";
	this.datasources["ldev119"] = server.getDatasource( "h2", "#getDirectoryFromPath( getCurrentTemplatePath() )#datasource/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		datasource: "ldev119"
	};
}
