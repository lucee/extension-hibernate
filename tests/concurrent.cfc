component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM concurrent sessions", function() {

			it( "handles multiple sequential ORM requests without session leaks", function() {
				var base = uri();
				var ids = [];

				// fire off multiple requests sequentially — each with its own session
				for ( var i = 1; i <= 5; i++ ) {
					var id = createUUID();
					ids.append( id );
					var result = _InternalRequest(
						template: "#base#/saveUnique.cfm",
						url: { entityId: id }
					);
					expect( trim( result.filecontent ) ).toBe( "ok" );
				}

				// verify all entities exist via a final request
				for ( var id in ids ) {
					var check = _InternalRequest(
						template: "#base#/saveUnique.cfm",
						url: { entityId: id }
					);
					// re-saving same ID should still work (update, not insert error)
					expect( trim( check.filecontent ) ).toBe( "ok" );
				}
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "concurrent";
	}

}
