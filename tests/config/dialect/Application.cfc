component {
	// dialect passed via URL param, or auto-detect if empty
	param name="url.testDialect" default="";

	this.name = "test-dialect-#hash( getCurrentTemplatePath() & url.testDialect )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-dialect-#hash( url.testDialect )#" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	if ( len( url.testDialect ) ) {
		this.ormSettings.dialect = url.testDialect;
	}
}
