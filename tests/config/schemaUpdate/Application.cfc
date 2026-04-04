component {
	// Phase 1 (dropcreate): create schema with v1 entity (id, name)
	// Phase 2 (update): expand schema with v2 entity (id, name, description)
	phase = url.phase ?: 1;
	entityDir = phase == 2 ? "entities_v2" : "entities_v1";
	db = url.db ?: "h2";

	this.name = "test-schemaUpdate-#db#-phase#phase#-#hash( getCurrentTemplatePath() )#";
	if ( db == "mysql" ) {
		this.datasource = server.getDatasource( "mysql" );
		this.ormSettings = {
			dbcreate: phase == 2 ? "update" : "dropcreate",
			dialect: "MySQL",
			cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) & entityDir ]
		};
	} else {
		this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-schemaUpdate" ) );
		this.ormSettings = {
			dbcreate: phase == 2 ? "update" : "dropcreate",
			cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) & entityDir ]
		};
	}
	this.ormEnabled = true;

	function onRequestStart() {
		ormReload();
	}
}
