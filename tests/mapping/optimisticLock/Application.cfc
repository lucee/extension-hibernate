component {
	this.name = "test-optimisticLock-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-optimisticLock" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		savemapping: true,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
