component {
	this.name = "test-cfclocation-mixed-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation-mixed" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [
			getDirectoryFromPath( getCurrentTemplatePath() ) & "good",
			getDirectoryFromPath( getCurrentTemplatePath() ) & "doesNotExist"
		]
	};
}
