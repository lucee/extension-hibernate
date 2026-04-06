component {
	this.name = "test-compositeKey-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-compositeKey" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM CompositeEntity" );
		queryExecute( "INSERT INTO CompositeEntity (keyPart1, keyPart2, label) VALUES ('a', 1, 'first')" );
		queryExecute( "INSERT INTO CompositeEntity (keyPart1, keyPart2, label) VALUES ('a', 2, 'second')" );
		queryExecute( "INSERT INTO CompositeEntity (keyPart1, keyPart2, label) VALUES ('b', 1, 'third')" );
	}
}
