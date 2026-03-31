component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Global event handler", function() {

			it( "emits pre/post insert events on flush", function() {
				var result = _InternalRequest( template: "#uri()#/insert.cfm" );
				var events = deserializeJSON( trim( result.filecontent ) );
				// preInsert fires on entity (none here), then global, then flush, then postInsert
				expect( events ).toInclude( "preInsert" );
				expect( events ).toInclude( "postInsert" );
				expect( events ).toInclude( "onFlush" );
			});

			it( "emits pre/post update events on flush", function() {
				var result = _InternalRequest( template: "#uri()#/update.cfm" );
				var events = deserializeJSON( trim( result.filecontent ) );
				expect( events ).toInclude( "preUpdate" );
				expect( events ).toInclude( "postUpdate" );
				expect( events ).toInclude( "onFlush" );
			});

			it( "emits pre/post delete events on flush", function() {
				var result = _InternalRequest( template: "#uri()#/delete.cfm" );
				var events = deserializeJSON( trim( result.filecontent ) );
				expect( events ).toInclude( "onDelete" );
				expect( events ).toInclude( "preDelete" );
				expect( events ).toInclude( "postDelete" );
				expect( events ).toInclude( "onFlush" );
			});

			it( "emits pre/post load events", function() {
				var result = _InternalRequest( template: "#uri()#/load.cfm" );
				var events = deserializeJSON( trim( result.filecontent ) );
				expect( events ).toInclude( "preLoad" );
				expect( events ).toInclude( "postLoad" );
			});

			it( "emits onClear", function() {
				var result = _InternalRequest( template: "#uri()#/clear.cfm" );
				var events = deserializeJSON( trim( result.filecontent ) );
				expect( events ).toInclude( "onClear" );
			});

			// onEvict: ormEvictEntity() evicts from the second-level cache via SessionFactory,
			// not from the session. Session.evict() would trigger the event, but there's
			// no CFML BIF that calls it.

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "globalEvents";
	}

}
