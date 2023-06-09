component {

	this.name	=	Hash( GetCurrentTemplatePath() ) & "2s";
	this.sessionManagement 	= false;

	
	this.mappings[ "testsRoot" ] = "/tests";
	this.mappings[ "luceeTestRoot" ] = this.mappings[ "testsRoot" ] & "/specs/luceeTests";
	server.helpers = new tests.specs.luceeTests.TestHelper();
	this.datasource =  server.helpers.getDatasource( "h2", expandPath("db") );

	// ORM settings
	this.ormEnabled = true;
	this.ormSettings = {
		// dialect = "MySQLwithInnoDB",
		// dialect = "MicrosoftSQLServer",
		dbcreate="dropcreate"
	};

	function onApplicationStart(){
		try{
			query {
				echo("DROP TABLE users");
			}
		}
		catch(local.e) {}

		query{
			echo("CREATE TABLE users( 
				id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
				DateJoined DATETIME )");
		}

	}

	
	public function onRequestStart() {
		setting requesttimeout=10 showdebugOutput=false;
	}
}