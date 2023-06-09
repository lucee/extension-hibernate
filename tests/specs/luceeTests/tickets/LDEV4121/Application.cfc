component {
	this.name = 'LDEV4121';
	this.ORMenabled = "true";
	this.ormSettings = {
		datasource = "testH2",
		dbCreate = "dropcreate",
		useDBForMapping = false,
		dialect = "h2"
	};
	this.datasources["testH2"] = server.helpers.getDatasource("h2", expandPath( "./db/LDEV4121") );
	this.datasource = "testH2";
}