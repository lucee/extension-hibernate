component {
	this.name = "LDEV1569-nullon";
	this.nullSupport = true;
	this.datasources["h2"] = server.getDatasource( "h2", "#getDirectoryFromPath( getCurrentTemplatePath() )#/datasource/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		datasource: "h2",
		dbcreate: "dropcreate",
		skipCFCWithError: false
	};
}
