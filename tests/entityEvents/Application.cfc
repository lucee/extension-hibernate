component {
	this.name = "test-entityEvents-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", "#getDirectoryFromPath( getCurrentTemplatePath() )#/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM Admin" );
		queryExecute( "DELETE FROM Users" );
		queryExecute( "DELETE FROM Auto" );
	}
}
