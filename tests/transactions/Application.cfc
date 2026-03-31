component {
	this.name = "test-transactions-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", "#getDirectoryFromPath( getCurrentTemplatePath() )#/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM Auto" );
	}
}
