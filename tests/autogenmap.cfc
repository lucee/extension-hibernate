component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

    function beforeAll(){
        cleanup()
    };

    function afterAll(){
        cleanup();
    };

    private function cleanup(){
        var files = [ "autogenmapFalse/test.cfc.hbm.xml" ];
        for ( var f in files ){
            if ( fileExists( f ) ){
                fileDelete( f );
            }
        }
    };

    public void function testAutoGenMap(){
        local.uri=createURI("autogenmap/index.cfm");
        local.result=_InternalRequest(uri);
        expect( result.status ).toBe( 200 );
        // var res = deserializeJson(result.fileContent);
        // if (len(res.errors)){
        //     loop array=res.errors, item="local.err"{
        //         systemOutput("ERROR: " & err.error, true, true);
        //     }
        // }
    }

    // check when autogenmap is false and the xml mapping files don't exist
    public void function testAutoGenMapMissing(){
        local.uri=createURI("autogenmapMissing/index.cfm");
        local.result=_InternalRequest(uri);
        expect( result.status ).toBe( 200 );
        // var res = deserializeJson(result.fileContent);
        // if (len(res.errors)){
        //     loop array=res.errors, item="local.err"{
        //         systemOutput("ERROR: " & err.error, true, true);
        //     }
        // }
    }

	private string function createURI(string calledName){
		systemOutput("", true);
		systemOutput("-------------- #calledName#----------------", true);
		var baseURI = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) );
		return baseURI&""&calledName;
	}
}