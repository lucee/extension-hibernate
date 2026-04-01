component {
	this.name = "test-relationships-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-relationships" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM Auto" );
		queryExecute( "DELETE FROM Dealership" );
	}
}
