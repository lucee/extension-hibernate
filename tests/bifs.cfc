component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "ORM BIF functions", function() {

			it( "entityNew()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityNew.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entitySave()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entitySave.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityLoad()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityLoad.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityLoadByPK()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityLoadByPK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityMerge()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityMerge.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityReload()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityReload.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityNameArray()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityNameArray.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityNameList()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityNameList.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormExecuteQuery()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/ormExecuteQuery.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormGetSession(), ormGetSessionFactory(), ormClearSession(), ormEvictEntity(), ormEvictQueries()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/ormSession.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "ormReload()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/ormReload.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityDelete()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityDelete.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "entityToQuery()", function() {
				var result = _InternalRequest( template: "#createURI( 'bifs' )#/entityToQuery.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function createURI( string calledName ) {
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI & calledName;
	}

}
