component {
	this.name = "test-hbmXML-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-hbmXML" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		savemapping: true,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
