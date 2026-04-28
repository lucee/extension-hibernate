component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		// Disabled: HBMCreator rejects fetch="subselect" at the extension validator
		// (HBMCreator.java:1683 — "valid values are [join,select]"). Hibernate itself
		// supports `subselect` natively as a fetch strategy. Removing the validator
		// gate would unlock a real Hibernate feature for CFML users — separate
		// follow-up from the H7.3 migration. xit until then.
		xdescribe( "fetch='subselect' on a one-to-many", function() {

			it( "subselect strategy loads collections for all parents in session", function() {
				var result = _InternalRequest( template: "#uri()#/probe.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "fetchSubselect";
	}

}
