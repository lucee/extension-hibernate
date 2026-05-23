component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "generator='foreign' with params={property='X'} where X doesn't exist on the entity (LDEV-6343)", function() {

			it( "throws localized error naming the missing property", function() {
				var actualMessage = "";
				try {
					_InternalRequest( template: "#uri()#/probe.cfm" );
					fail( "expected ORM init to throw, but it succeeded" );
				}
				catch ( any e ) {
					actualMessage = e.message;
				}

				expect( actualMessage ).toInclude( "foreign", "expected message to mention generator [foreign]; got: " & actualMessage );
				expect( actualMessage ).toInclude( "BadProperty", "expected message to localize to entity [BadProperty]; got: " & actualMessage );
				expect( actualMessage ).toInclude( "nonexistent", "expected message to name the missing property; got: " & actualMessage );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "generatorForeignBadProperty";
	}

}
