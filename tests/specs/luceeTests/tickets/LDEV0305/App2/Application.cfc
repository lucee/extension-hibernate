component {

	this.name = hash( getCurrentTemplatePath() );


	variables.suffix = "entity";

	this.datasource = "mysql";

	this.ormEnabled  = true;
	this.ormSettings = {
		dialect : "MySQLwithInnoDB"
		// dialect="MicrosoftSQLServer"
	};

	public function onRequestStart(){
		setting requesttimeout=10;
	}

}
