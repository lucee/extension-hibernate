component {
	this.name = "test-skipCFCWithError-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-skipCFCWithError" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		skipCFCWithError: true,
		cfclocation: [
			getDirectoryFromPath( getCurrentTemplatePath() ),
			getDirectoryFromPath( getCurrentTemplatePath() ) & "badEntity"
		]
	};
}
