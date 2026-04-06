component {
	this.name = "test-entityLoadFilters-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-entityLoadFilters" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		secondarycacheenabled: true,
		cacheprovider: "ehcache",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM FilterEntity" );
		queryExecute( "INSERT INTO FilterEntity (id, name, status, category) VALUES (1, 'alpha', 'active', 'books')" );
		queryExecute( "INSERT INTO FilterEntity (id, name, status, category) VALUES (2, 'bravo', 'active', 'games')" );
		queryExecute( "INSERT INTO FilterEntity (id, name, status, category) VALUES (3, 'charlie', 'inactive', 'books')" );
		queryExecute( "INSERT INTO FilterEntity (id, name, status, category) VALUES (4, 'delta', 'active', 'books')" );
		queryExecute( "INSERT INTO FilterEntity (id, name, status, category) VALUES (5, 'echo', 'inactive', 'games')" );
	}
}
