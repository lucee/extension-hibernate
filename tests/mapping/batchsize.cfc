component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "batchsize attribute [H2]", function() {

			it( "relationship batchsize: loads all books across publishers", function() {
				var result = _InternalRequest( template: "#uri()#/relationshipBatchsize.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "batchsize";
	}

}
