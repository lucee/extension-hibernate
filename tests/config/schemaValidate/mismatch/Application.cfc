component {
	// Uses the SAME MySQL datasource — schema already created by dropcreate
	// but this entity has an extra column that doesn't exist in the DB
	this.name = "test-schemaValidate-mismatch-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "mysql" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "validate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
