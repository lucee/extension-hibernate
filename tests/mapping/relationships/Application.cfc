component {
	this.name = "test-relationships-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-relationships" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM Auto" );
		queryExecute( "DELETE FROM Dealership" );
		try { queryExecute( "DELETE FROM student_course" ); } catch( any e ) {}
		try { queryExecute( "DELETE FROM Student" ); } catch( any e ) {}
		try { queryExecute( "DELETE FROM Course" ); } catch( any e ) {}
	}
}
