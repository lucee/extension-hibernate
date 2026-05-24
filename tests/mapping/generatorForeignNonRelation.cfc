component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "generator='foreign' with property reference that exists but is not a relation (LDEV-6343)", function() {

			it( "throws localized error noting the property has no cfc attribute", function() {
				var actualMessage = "";
				try {
					_InternalRequest( template: "#uri()#/probe.cfm" );
					fail( "expected ORM init to throw, but it succeeded" );
				}
				catch ( any e ) {
					actualMessage = e.message;
				}

				expect( actualMessage ).toInclude( "foreign", "expected message to mention generator [foreign]; got: " & actualMessage );
				expect( actualMessage ).toInclude( "NonRelation", "expected message to localize to entity [NonRelation]; got: " & actualMessage );
				expect( actualMessage ).toInclude( "name", "expected message to name the non-relation property; got: " & actualMessage );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "generatorForeignNonRelation";
	}

}
