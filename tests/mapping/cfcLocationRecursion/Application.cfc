component {
	this.name = "test-cfclocation-recursion-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation-recursion" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		// Recurses into ./child/entities/, picking up entities that reference
		// cfc="childns.Bar" — a mapping only the child Application.cfc declares.
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
