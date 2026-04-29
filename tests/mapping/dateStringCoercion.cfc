component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "string-to-date parameter coercion in finders + HQL", function() {

			it( "entityLoad filter struct accepts a date string", function() {
				var result = _InternalRequest( template: "#uri()#/entityLoadStringDate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormExecuteQuery accepts a String for a Date param", function() {
				var result = _InternalRequest( template: "#uri()#/hqlStringDate.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "dateStringCoercion";
	}

}
