component {

	this.name                       = "LDEV-3907";
	this.ormenabled                 = true;
	this.ormsettings                = { dbcreate : "dropCreate", dialect : "MicrosoftSQLServer" }
	mssql                           = server.helpers.getDatasource( "mssql" );
	this.datasources[ "LDEV_3907" ] = mssql;
	this.datasource                 = "LDEV_3907";

	public function onRequestStart(){
		if ( structIsEmpty( mssql ) ) {
			writeOutput( "Datasource credentials was not available" ); // Datasource credentials was not available means need to skip the iteration.
			abort;
		}
	}
	public function onRequestEnd(){
		if ( structIsEmpty( mssql ) ) return;
	}

	private struct function getDatasource(){
		return server.helpers.getDatasource( "mssql" );
	}

}
