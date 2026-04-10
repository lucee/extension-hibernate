component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Hibernate version string", function() {

			it( "should match the hibernate-core jar version", function() {
				var versionClass = createObject( "java", "org.hibernate.Version" );
				var reportedVersion = versionClass.getVersionString();
				var jarVersion = versionClass.getClass().getPackage().getImplementationVersion();
				systemOutput( "Hibernate reported: #reportedVersion#, jar manifest: #( jarVersion ?: 'null' )#", true );
				expect( reportedVersion ).notToBe( "[WORKING]",
					"Version.getVersionString() must not return [WORKING] - set Implementation-Version in the shaded jar manifest" );
				expect( reportedVersion ).toBe( jarVersion,
					"Version.getVersionString() should match the Implementation-Version from the jar manifest" );
			});

		});

	}

}
