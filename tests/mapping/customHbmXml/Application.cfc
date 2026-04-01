component {
	this.name = "test-customHbmXml-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-customHbmXml" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		autogenmap: false,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
