component {
	this.name = "test-dynamicSQL-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-dynamicSQL" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		savemapping: true,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
