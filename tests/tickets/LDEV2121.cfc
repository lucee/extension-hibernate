component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {
		describe( "LDEV-2121 struct as composite primary key", function() {

			it( "entityLoadByPK() accepts a struct for a composite primary key", function() {
				local.result = _InternalRequest( template: "#createURI( 'LDEV2121' )#/loadByPK.cfm" );
				expect( trim( result.filecontent ) ).toBe( "second" );
			});

			it( "entityLoadByPK() reports a missing composite key property", function() {
				local.result = _InternalRequest( template: "#createURI( 'LDEV2121' )#/missingKey.cfm" );
				expect( trim( result.filecontent ) ).toInclude( "[k2]" );
			});

			it( "ormEvictEntity() accepts a struct for a composite primary key", function() {
				local.result = _InternalRequest( template: "#createURI( 'LDEV2121' )#/evict.cfm" );
				local.data = deserializeJSON( trim( result.filecontent ) );
				expect( data.beforeA ).toBeTrue();
				expect( data.beforeB ).toBeTrue();
				expect( data.afterA ).toBeFalse();
				expect( data.afterB ).toBeTrue();
			});

		});
	}

	private string function createURI( string calledName ) {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & calledName;
	}

}
