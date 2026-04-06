component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "flushAtRequestEnd=true behaviour [H2]", function() {

			it( "entitySave without ormFlush persists at end of request", function() {
				var id = createGUID();
				// request 1: save without flush
				var r1 = _InternalRequest(
					template: "#uri()#/autoFlushPersists.cfm",
					urls: { action: "save", testId: id }
				);
				expect( trim( r1.filecontent ) ).toInclude( "saved:" );
				// request 2: verify it persisted
				var r2 = _InternalRequest(
					template: "#uri()#/autoFlushPersists.cfm",
					urls: { action: "verify", testId: id }
				);
				expect( trim( r2.filecontent ) ).toBe( "count:1" );
			});

			it( "dirty entity mutated without entitySave persists at end of request", function() {
				var id = createGUID();
				// request 1: setup entity
				_InternalRequest(
					template: "#uri()#/dirtyEntityPersists.cfm",
					urls: { action: "setup", testId: id }
				);
				// request 2: load and mutate without save/flush
				_InternalRequest(
					template: "#uri()#/dirtyEntityPersists.cfm",
					urls: { action: "mutate", testId: id }
				);
				// request 3: verify the mutation persisted
				var r3 = _InternalRequest(
					template: "#uri()#/dirtyEntityPersists.cfm",
					urls: { action: "verify", testId: id }
				);
				expect( trim( r3.filecontent ) ).toBe( "name:Mutated" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "flushAtRequestEnd";
	}

}
