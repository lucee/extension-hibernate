component {
	this.name = "LDEV4150"
	this.ORMenabled = true;
	this.datasource = server.getDatasource("mysql");
	this.ormSettings = {
		dbcreate = "dropcreate",
		dialect = "MySql"
	};
}