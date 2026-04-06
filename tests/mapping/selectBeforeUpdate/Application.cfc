component {
	this.name = "test-selectBeforeUpdate-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-selectBeforeUpdate" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		savemapping: true,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
