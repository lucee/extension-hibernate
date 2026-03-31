component {
	this.name = "test-dbMapping-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-dbMapping" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "update",
		useDBForMapping: true,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
