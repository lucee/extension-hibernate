component {
	this.name = "test-generators-postgres-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "postgres" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		ormReload();
	}
}
