component {
	this.name = "test-relationships-dotted-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-relationships-dotted" ) );
	this.ormEnabled = true;
	this.mappings = {
		"/dotted" = getDirectoryFromPath( getCurrentTemplatePath() ) & "entities"
	};
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) & "entities" ]
	};
}
