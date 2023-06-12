component {

	this.name       = "orm" & hash( getCurrentTemplatePath() );
	this.ORMenabled = true;

	this.ormSettings.dbcreate = "dropcreate";
	this.ormSettings.dialect  = "mysql";

	this.datasource = server.helpers.getDatasource( "mssql" );

	public function onRequestStart(){
		setting requesttimeout=10;
	}

}
