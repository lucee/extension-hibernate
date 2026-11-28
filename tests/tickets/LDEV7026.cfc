component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV7026" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-7026 a lazy proxy loaded before transaction{} must initialize inside the block", function() {

			var scenarios = [ "proxy", "proxyAfterQuery", "proxyLoadByPK", "collection", "saveThenProxy" ];
			for ( var autoManage in [ true, false ] ) {
				for ( var scenario in scenarios ) {
					it( title="#scenario# as the first ORM read in transaction{} (autoManageSession=#autoManage#)",
						data={ scenario: scenario, autoManage: autoManage },
						body=function( data ) {
							var result = _InternalRequest(
								template: "#uri#/proxyThenTransaction.cfm",
								url: { scenario: data.scenario, autoManage: data.autoManage }
							);
							expect( trim( result.filecontent ) ).toBe( "ok" );
						}
					);
				}
			}

		});
	}

	private string function createURI( string calledName ) {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & calledName;
	}

}
