component {
	this.name = "test-cfclocation-overlap-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation-overlap" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [
			getDirectoryFromPath( getCurrentTemplatePath() ) & "all",
			getDirectoryFromPath( getCurrentTemplatePath() ) & "all/inner"
		]
	};
}
