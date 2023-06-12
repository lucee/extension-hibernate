component {

	this.name        = "LDEV4067";
	this.ORMenabled  = "true";
	this.ormSettings = {
		datasource      : "testH2",
		dbCreate        : "dropcreate",
		useDBForMapping : false,
		dialect         : "h2"
	};
	this.datasources[ "testH2" ] = server.helpers.getDatasource( "h2", expandPath( "./db/LDEV4067" ) );

}
