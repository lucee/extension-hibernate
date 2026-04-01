component {
	this.name = "test-globalEvents-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-globalEvents" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		eventHandler: "eventHandler"
	};

	function onRequestStart() {
		application.ormEventLog = [];
		queryExecute( "DELETE FROM Auto" );
	}
}
