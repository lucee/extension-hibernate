component {
	this.name = "test-linkSchema-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "mysql" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		// create the link schema (MySQL database) if it doesn't exist
		try {
			queryExecute( "CREATE DATABASE IF NOT EXISTS orm_link_schema_test" );
		} catch ( any e ) {
			// may not have CREATE DATABASE privilege — test will fail gracefully
		}
		// cleanup orphaned data from previous runs
		try { queryExecute( "DELETE FROM orm_link_schema_test.ls_enrollment" ); } catch ( any e ) {}
		try { queryExecute( "DELETE FROM LS_Student" ); } catch ( any e ) {}
		try { queryExecute( "DELETE FROM LS_Course" ); } catch ( any e ) {}
		ormReload();
	}
}
