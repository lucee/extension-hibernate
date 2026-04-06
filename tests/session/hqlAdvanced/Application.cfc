component {
	this.name = "test-hqlAdvanced-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-hqlAdvanced" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		// Book has FK to Author — delete children first
		queryExecute( "DELETE FROM HqlBook" );
		queryExecute( "DELETE FROM HqlAuthor" );
	}
}
