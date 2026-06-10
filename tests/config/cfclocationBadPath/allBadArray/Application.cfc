component {
	this.name = "test-cfclocation-allbad-array-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation-allbad-array" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [
			getDirectoryFromPath( getCurrentTemplatePath() ) & "doesNotExistA",
			getDirectoryFromPath( getCurrentTemplatePath() ) & "doesNotExistB"
		]
	};
}
