component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Inheritance mapping [H2]", function() {

			describe( "Table-per-hierarchy (discriminator)", function() {

				it( "round-trip: save Car and Truck, load as Vehicle", function() {
					var result = _InternalRequest( template: "#uri()#/tphRoundTrip.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

				it( "polymorphic load: entityLoadByPK('Vehicle') returns correct subclass", function() {
					var result = _InternalRequest( template: "#uri()#/tphPolymorphicLoad.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

				it( "HQL polymorphic query returns mixed subclass types", function() {
					var result = _InternalRequest( template: "#uri()#/tphHqlPolymorphic.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

			});

			describe( "Table-per-subclass (joined)", function() {

				it( "round-trip: save Employee, load as Person, verify joined tables", function() {
					var result = _InternalRequest( template: "#uri()#/tpsRoundTrip.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

			});

			describe( "Table-per-concrete-class (union)", function() {

				it( "round-trip: save Circle, load as Shape, verify own table with all columns", function() {
					var result = _InternalRequest( template: "#uri()#/tpcRoundTrip.cfm" );
					expect( trim( result.filecontent ) ).toBe( "ok" );
				});

			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "inheritance";
	}

}
