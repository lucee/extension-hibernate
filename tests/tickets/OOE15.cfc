/**
 * OOE-15 / LDEV-305: ID property without explicit ormtype maps as double instead of integer
 *
 * When an entity ID uses generator="native" but omits ormtype, the type resolution
 * chain falls back to prop.getType(). In Lucee 4.5 this returned "numeric" which
 * mapped to "double" — an invalid Hibernate identifier type. Modern Lucee (6.2+)
 * returns "any" which falls through to the generator default of "integer".
 *
 * Cannot reproduce on current Lucee versions, but kept as a regression guard.
 *
 * @see NativeIdEntity.cfc — ID with generator="native", no ormtype
 */
component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "OOE-15 / LDEV-305: ID property without ormtype + generator=native", function() {

			// Entity with generator="native" and no explicit ormtype should auto-generate
			// an integer ID, not fail with "Bad identifier type: double"
			it( "native generator ID works without explicit ormtype", function() {
				var result = _InternalRequest( template: "#uri()#/test.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "OOE15";
	}

}
