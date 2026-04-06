component {
	this.name = "test-hqlParams-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-hqlParams" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		// seed test data fresh each request
		queryExecute( "DELETE FROM HqlEntity" );
		queryExecute( "INSERT INTO HqlEntity (id, name, price, active, created) VALUES (1, 'alpha', 9.99, true, '2025-06-15')" );
		queryExecute( "INSERT INTO HqlEntity (id, name, price, active, created) VALUES (2, 'bravo', 19.99, false, '2025-07-20')" );
		queryExecute( "INSERT INTO HqlEntity (id, name, price, active, created) VALUES (3, 'charlie', 29.99, true, '2025-08-25')" );
		queryExecute( "INSERT INTO HqlEntity (id, name, price, active, created) VALUES (4, 'alpha', 39.99, true, '2025-09-30')" );
		queryExecute( "INSERT INTO HqlEntity (id, name, price, active, created) VALUES (5, 'echo', 49.99, false, '2025-10-05')" );
	}
}
