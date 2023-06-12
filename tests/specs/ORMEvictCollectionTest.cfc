component extends="testbox.system.BaseSpec" {

	public void function run(){
		describe( "ormEvictCollection()", () => {
			it( "Can evict collection (relation) on an entity type", () => {
				// these are pretty bad/useless tests. :/
				transaction {
					ormEvictCollection( "Dealership", "inventory" );
				}
			} );
			it( "Can evict collection item by ID", () => {
				// these are pretty bad/useless tests. :/
				transaction {
					ormEvictCollection( "Dealership", "inventory", "12345" );
				}
			} );
		} );
	}

}
