component {
	this.name = "test-cfclocation-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [
			getDirectoryFromPath( getCurrentTemplatePath() ) & "entities_a",
			getDirectoryFromPath( getCurrentTemplatePath() ) & "entities_b"
		]
	};
}
