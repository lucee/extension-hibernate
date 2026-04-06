component {
	this.name = "test-batchsize-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-batchsize" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		savemapping: true,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
