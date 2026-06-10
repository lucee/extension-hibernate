component {
	this.name = "test-cfclocation-bad-string-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation-bad-string" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: getDirectoryFromPath( getCurrentTemplatePath() ) & "doesNotExist"
	};
}
