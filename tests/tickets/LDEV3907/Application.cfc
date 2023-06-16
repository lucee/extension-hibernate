component {
	this.name = "LDEV-3907";
	this.ormenabled = true;
	this.ormsettings = {
		dbcreate="dropCreate"
		,dialect="MicrosoftSQLServer"
	} 
	mssql = getDatasource();
	this.datasources["LDEV_3907"] = server.getDatasource("mssql");
	this.datasource = "LDEV_3907";
}