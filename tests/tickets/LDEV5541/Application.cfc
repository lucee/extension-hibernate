component {
	this.name = "ldev-5541";
	this.ORMenabled = true;
	this.datasource = server.getDatasource("mysql");
	this.ormSettings = {
		dbcreate = "dropcreate",
		dialect = "mysql"
	};
}