component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( title="ORM deadlock error messages [mysql]", skip=notHasMySQL(), body=function() {

			it( "deadlock error message mentions deadlock, not just 'could not execute statement'", function() {
				var result = _InternalRequest( template: "#uri()#/deadlockError.cfm" );
				var lines = listToArray( trim( result.filecontent ), chr( 10 ) );
				var data = {};
				for ( var line in lines ) {
					var parts = listToArray( line, "=", false, true );
					if ( arrayLen( parts ) >= 2 )
						data[ trim( parts[1] ) ] = trim( parts[2] );
					else if ( arrayLen( parts ) == 1 )
						data[ trim( parts[1] ) ] = "";
				}

				// At least one thread must have errored (deadlock victim)
				var hadDeadlock = ( structKeyExists( data, "t1" ) && data.t1 == "error" )
					|| ( structKeyExists( data, "t2" ) && data.t2 == "error" );
				expect( hadDeadlock ).toBeTrue( "Expected at least one thread to hit a deadlock" );

				// The error message should mention "deadlock" — not just "could not execute statement"
				var msg = structKeyExists( data, "msg" ) ? data.msg : "";
				expect( lCase( msg ) ).toInclude( "deadlock",
					"Error message should mention 'deadlock' but got: [#msg#]" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "deadlock";
	}

	private boolean function notHasMySQL() {
		return isEmpty( server.getDatasource( "mysql" ) );
	}

}
