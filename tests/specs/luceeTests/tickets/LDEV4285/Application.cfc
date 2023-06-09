component {
	this.name = 'LDEV4285';
	this.ORMenabled = "true";
	this.ORMsettings = {
		datasource = "LDEV4285",
		dbCreate = "dropCreate",
		dialect = " MySQL"
	}
	this.datasource = "LDEV4285";
	this.datasources["LDEV4285"] = server.helpers.getDatasource( "h2", expandPath("db") );
}