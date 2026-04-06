component {
	this.name = "test-inheritance-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-inheritance" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		savemapping: true,
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		// cleanup all tables to avoid cross-test data bleed
		try { queryExecute( "DELETE FROM TPH_Vehicle" ); } catch( any e ) {}
		try { queryExecute( "DELETE FROM TPS_Employee" ); } catch( any e ) {}
		try { queryExecute( "DELETE FROM TPS_Person" ); } catch( any e ) {}
		try { queryExecute( "DELETE FROM TPC_Circle" ); } catch( any e ) {}
		try { queryExecute( "DELETE FROM TPC_Shape" ); } catch( any e ) {}
	}
}
