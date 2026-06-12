component {
	this.name = "LDEV-6390";
	this.datasources[ "ldev6390" ] = server.getDatasource( "h2", "#getDirectoryFromPath( getCurrentTemplatePath() )#datasource/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		datasource: "ldev6390"
	};
}
