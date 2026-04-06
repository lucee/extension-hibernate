component {
	this.name = "test-nativeIdInsert-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-nativeIdInsert" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		flushAtRequestEnd: false,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
