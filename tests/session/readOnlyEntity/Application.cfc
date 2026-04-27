component {
	this.name = "test-readOnlyEntity-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-readOnlyEntity" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM RO_Child" );
		queryExecute( "DELETE FROM RO_Parent" );
		queryExecute( "INSERT INTO RO_Parent ( id, name ) VALUES ( 'p1', 'parent-one' )" );
		queryExecute( "INSERT INTO RO_Child ( id, name, parentId ) VALUES ( 'c1', 'child-one', 'p1' )" );
		queryExecute( "INSERT INTO RO_Child ( id, name, parentId ) VALUES ( 'c2', 'child-two', 'p1' )" );
	}
}
