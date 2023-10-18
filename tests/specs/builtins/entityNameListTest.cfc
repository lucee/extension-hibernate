component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "entityNameList()", () => {
			it( "will return entity name string", () => {
				expect( entityNameList() ).toBeString();
			} );
			it( "will return known entities", () => {
				expect( listToArray( entityNameList(), "," ) )
					.toInclude( "Auto" )
					.toInclude( "Dealership" )
					.toInclude( "User" );
			} );
			it( "will use the passed delimiter", () => {
				expect( listToArray( entityNameList( "|" ), "|" ) )
					.toInclude( "Auto" )
					.toInclude( "Dealership" )
					.toInclude( "User" );
			} );
		} );
	}

}
