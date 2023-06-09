component {
	this.name = hash( getCurrentTemplatePath() );
    request.baseURL="http://#cgi.HTTP_HOST##GetDirectoryFromPath(cgi.SCRIPT_NAME)#";

	this.datasource= "mysql";

	this.ormEnabled = true;
	this.ormSettings = {
		dialect="MySQLwithInnoDB"
		// dialect="MicrosoftSQLServer"
	};
	
	public function onRequestStart() {
		setting requesttimeout=10;
	}
}