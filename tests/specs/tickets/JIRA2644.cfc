/**
 * Tests for Railo Jira-2644
 */
component extends="testbox.system.BaseSpec" {

	function afterAll(){
		// Cleanup so we can re-run tests
		ormClearSession();
		transaction {
			queryExecute( "DELETE FROM State_2644" );
			ormFlush();
		}
	}

	function run( testResults, testBox ){
		describe( "Railo Jira-2644 - composite ID tests", function(){
			it( "can save entity with composite ID", function(){
				transaction {
					var newState = entityNew( "State" );
					newState.setStateCode( "CA" );
					newState.setCountryCode( "US" );
					newState.setSusi( "Sorglos" );
					entitySave( newState );
					ormFlush();

					// ensure we load from DB, not from the session
					ormClearSession();
					var theState = arrayFirst( entityLoad( "State" ) );

					expect( theState.getStateCode() ).toBe( "CA" );
					expect( theState.getCountryCode() ).toBe( "US" );
				}
			} );
			it( "can serialize an array of composite ID entities", function(){
				expect( () => {
					transaction {
						var bestsellers = entityLoad( "bestseller", {}, "gender desc, sortorder" );
						serialize( bestsellers );
					}
				} ).notToThrow();
			} );
			it( "can delete by composite key struct", function(){
				var toDelete = entityLoad( "State", { stateCode : "CA", countryCode : "US" } );
				if ( !isNull( toDelete ) ) {
					entityDelete( toDelete );
				}
			} )
		} );
	}

}
