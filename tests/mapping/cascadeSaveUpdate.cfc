component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		// Locks the cascade="save-update" contract on H5 so the gap on H7.3+ is
		// caught when this spec is cherry-picked. See h73-testgaps.md gap #1.
		describe( "cascade='save-update' on a one-to-many", function() {

			it( "entitySave(parent) cascades to transient children", function() {
				var result = _InternalRequest( template: "#uri()#/cascadePersistsChildren.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "cascadeSaveUpdate";
	}

}
