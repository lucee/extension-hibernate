component {
	this.name = "test-cfclocation-recursion-child-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation-recursion-child" ) );
	this.ormEnabled = true;
	this.mappings = {
		"/childns" = getDirectoryFromPath( getCurrentTemplatePath() ) & "entities"
	};
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) & "entities" ]
	};
}
