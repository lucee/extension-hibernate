component {
	this.name = "test-hqlCase-#hash( getCurrentTemplatePath() )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-hqlCase" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	function onRequestStart() {
		queryExecute( "DELETE FROM HqlCaseCustomer" );
		queryExecute( "INSERT INTO HqlCaseCustomer (id, UserName, EmailAddress, BirthDate) VALUES (1, 'JohnSmith', 'john@example.com', '1980-01-01')" );
		queryExecute( "INSERT INTO HqlCaseCustomer (id, UserName, EmailAddress, BirthDate) VALUES (2, 'JaneDoe',   'jane@example.com', '1985-06-15')" );
		queryExecute( "INSERT INTO HqlCaseCustomer (id, UserName, EmailAddress, BirthDate) VALUES (3, 'BobBrown',  'bob@example.com',  '1990-12-31')" );
	}
}
