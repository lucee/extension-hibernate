component {
	this.name = "test-sqlScript-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-sqlScript" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		sqlScript: getDirectoryFromPath( getCurrentTemplatePath() ) & "seed.sql"
	};

}
