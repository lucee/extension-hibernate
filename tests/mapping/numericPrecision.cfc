component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "precision / scale attributes [H2]", function() {

			it( "big_decimal with precision=12, scale=4 round-trips correctly", function() {
				var result = _InternalRequest( template: "#uri()#/precisionScale.cfm" );
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			// Hibernate 7.3+ rejects `scale` on floating-point ormtypes (double, float, real)
			// at SF build. Fixed-point types (big_decimal, integer) are unaffected.
			// This locks the strictness in — change it deliberately if Hibernate ever softens.
			// Lives in a sibling app dir (`numericPrecisionScaleError`) so the bad CFC isn't
			// picked up by this dir's cfclocation scan and doesn't poison the valid test above.
			it( "scale on a double ormtype throws at SF build (H7.3 strict)", function() {
				var sibling = getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "numericPrecisionScaleError/trigger.cfm";
				var caught  = "";
				try {
					_InternalRequest( template: sibling );
				} catch ( any e ) {
					caught = e.message & " | " & ( e.detail ?: "" );
				}
				// must NOT silently pass and must surface a recognisable explanation
				expect( caught ).toIncludeWithCase( "scale" );
				expect( caught ).toIncludeWithCase( "floating point" );
			});

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "numericPrecision";
	}

}
