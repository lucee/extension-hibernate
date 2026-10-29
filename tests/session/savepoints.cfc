component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {
		describe( title="ORM Savepoint Support", skip=notSupported(), body=function() {

			it( title="can use transaction savepoint", body=function( currentSpec ) {
				var result = _InternalRequest( template: createURI( "savepoints/index.cfm" ) );
				expect( result.status ).toBe( 200 );
				expect( trim( result.fileContent ) ).toBe( "ok" );
			});

			it( title="rollback to a transaction savepoint only undoes the ORM changes made after it", body=function( currentSpec ) {
				var result = _InternalRequest( template: createURI( "savepoints/rollback.cfm" ) );
				expect( result.status ).toBe( 200 );
				expect( trim( result.fileContent ) ).toBe( "ok" );
			});

		});
	}

	// LDEV-3657: savepoints with ORM code need the fix in Lucee core
	private boolean function notSupported() {
		return !server.checkVersionGTE( server.lucee.version, 7, 1, 3, 64 );
	}

	private string function createURI(string calledName){
		systemOutput("", true);
		systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
}
