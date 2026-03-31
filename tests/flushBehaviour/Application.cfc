component {
	this.name = "test-flushBehaviour-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-flushBehaviour" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ],
		flushAtRequestEnd: false,
		autoManageSession: false
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM Auto" );
	}
}
