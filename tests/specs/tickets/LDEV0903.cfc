/**
 * Tests for LDEV-0903
 * https://luceeserver.atlassian.net/browse/LDEV-903
 */
component extends="testbox.system.BaseSpec" {

	function afterAll(){
		// Cleanup so we can re-run tests
		transaction {
			queryExecute( "DELETE FROM Roster_Embargoes" );
			ormFlush();
		}
	}

	function run( testResults, testBox ){
		describe( "LDEV-0903 - working with composite keys", function(){
			it( "Can save an entity with a composite key", function(){
				transaction isolation="read_uncommitted" {
					var testEntity = entityNew( "RosterEmbargo" );
					testEntity.setteamID( "E6983EDD-BBEB-43D3-BEC2-C648660142C7" ); // string
					testEntity.setseasonID( 1 ); // int
					testEntity.setseasonUID( "1" ); // string
					testEntity.setembargoDate( now() ); // timestamp
					entitySave( testEntity );
				}
			} );
			it( "can load an entity by filtering on part of a composite key", function(){
				transaction isolation="read_uncommitted" {
					var testEntity = entityLoad(
						"RosterEmbargo",
						{ teamID : "E6983EDD-BBEB-43D3-BEC2-C648660142C7" },
						true
					);
					entitySave( testEntity );
				}
			} )
		} );
	}

}
