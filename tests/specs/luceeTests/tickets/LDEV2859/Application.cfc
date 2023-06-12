component {

	this.Name              = "LDEV2859";
	this.sessionManagement = false;
	this.ormEnabled        = true;
	// this.datasource = "LDEV2859";
	this.datasource        = "mssql";
	this.ormSettings       = {
		dbCreate        : "none",
		useDBForMapping : false,
		dialect         : "MicrosoftSQLServer"
	};

	msSql.storage = true;


	public function onRequestStart(){
		setting requesttimeout=10;
		query {
			echo( "DROP TABLE IF EXISTS test" );
		}
		query {
			echo( "CREATE TABLE test( id int, name varchar(20))" );
		}
		query {
			echo( "INSERT INTO test VALUES( '1', 'lucee' )" );
			echo( "INSERT INTO test VALUES( '2', 'railo' )" );
		}
	}

	public function onRequestEnd(){
		query {
			echo( "DROP TABLE IF EXISTS test" );
		}
	}

}
