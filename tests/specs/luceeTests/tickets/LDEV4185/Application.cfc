component {

	this.name = "LDEV-4185" & hash( getCurrentTemplatePath() );
	this.datasource= server.helpers.getDatasource("h2", expandPath( "./db/LDEV4185") );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate = "dropcreate"
	};


	public function onRequestStart() {
		setting requesttimeout=10;
	}

}