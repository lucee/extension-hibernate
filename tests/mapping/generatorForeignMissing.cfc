component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "generator='foreign' referencing a missing CFC (LDEV-6343)", function() {

			it( "throws at ORM init with foreign + entity + missing-CFC name in the message", function() {
				// ORM init runs during Application.cfc evaluation inside _InternalRequest,
				// so the probe template never executes — the throw propagates here.
				var actualMessage = "";
				try {
					_InternalRequest( template: "#uri()#/probe.cfm" );
					fail( "expected ORM init to throw, but it succeeded" );
				}
				catch ( any e ) {
					actualMessage = e.message;
				}

				systemOutput( "", true );
				systemOutput( "=== generatorForeignMissing captured ===", true );
				systemOutput( "message: " & actualMessage, true );
				systemOutput( "=== end ===", true );

				// LDEV-6342 contract — these tokens should all appear in the message
				// after the fix at HBMCreator:743. Currently: "foreign" is absent
				// because the user-visible error comes from a different code path
				// (SessionFactoryData.getEntityByCFCName) that doesn't localize to
				// the source property/entity.
				expect( actualMessage ).toInclude( "foreign", "expected message to mention generator [foreign]; got: " & actualMessage );
				expect( actualMessage ).toInclude( "PersonDetail", "expected message to localize the bad reference to entity [PersonDetail]; got: " & actualMessage );
				expect( actualMessage ).toInclude( "DoesNotExistAtAll", "expected message to name the missing CFC; got: " & actualMessage );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "generatorForeignMissing";
	}

}
