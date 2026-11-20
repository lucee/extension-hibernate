component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		variables.uri = createURI( "LDEV6941" );
	}

	function run( testResults, testBox ) {
		describe( "LDEV-6941 ORM work outside a transaction must not keep transaction{} on a separate connection", function() {

			var scenarios = [ "none", "save", "saveFlush", "saveClear", "reload" ];
			for ( var autoManage in [ true, false ] ) {
				for ( var scenario in scenarios ) {
					it( title="ORM and queryExecute() share the transaction{} connection after #scenario# outside (autoManageSession=#autoManage#)",
						data={ scenario: scenario, autoManage: autoManage },
						body=function( data ) {
							var result = _InternalRequest(
								template: "#uri#/ormThenTransaction.cfm",
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
