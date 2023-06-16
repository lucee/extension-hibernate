component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll(){
		cleanup();
	};

	function afterAll(){
		cleanup();
	};

	private function cleanup(){
		var files = [ "./autogenmapMissing/test.cfc.hbm.xml" ];
		for ( var f in files ){
			if ( fileExists( f ) ){
				fileDelete( f );
			}
		}
	};

	
	function run( testResults, testBox ){
		// all your suites go here.
		describe( "testing orm autogenmap support", function(){

			it( "test autogenmap", function(){
				local.uri=createURI("autogenmap/index.cfm");
				local.result=_InternalRequest(uri);
				expect( result.status ).toBe( 200 );
			} );

			it( "test autogenmap=false and missing xml mapping file", function(){
				local.uri=createURI("autogenmapMissing/index.cfm");
				expect( function(){
					local.result=_InternalRequest(
						template: uri,
						url: {
							autogenmap: false
						}
					);
				}).toThrow( regex="Hibernate mapping not found for entity" ); // ACF creates it, Lucee throws a useful error
			} );

			it( "test autogenmap=true and missing xml mapping file", function(){
				cleanup();
				local.uri=createURI("autogenmapMissing/index.cfm");
				local.result=_InternalRequest(
					template: uri,
					url: {
						autogenmap: true
					}
				);
				expect( result.fileContent.trim() ).toBe( "testing");
			} );

		} );
	}
	private string function createURI(string calledName){
		//systemOutput("", true);
		//systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
}