component {
	this.name = "test-uniqueResultMulti-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-uniqueResultMulti" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM MultiEntity" );
		queryExecute( "INSERT INTO MultiEntity ( id, name, status ) VALUES ( 1, 'alpha',   'active' )" );
		queryExecute( "INSERT INTO MultiEntity ( id, name, status ) VALUES ( 2, 'bravo',   'active' )" );
		queryExecute( "INSERT INTO MultiEntity ( id, name, status ) VALUES ( 3, 'charlie', 'active' )" );
		queryExecute( "INSERT INTO MultiEntity ( id, name, status ) VALUES ( 4, 'delta',   'inactive' )" );
	}
}
