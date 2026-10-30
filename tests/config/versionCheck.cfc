component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	// the extension and Hibernate are Maven libraries, load them through the extension's Maven coordinate
	private string function hibernateArtifact() {
		var q = extensionList();
		loop query=q {
			if ( q.id == "FAD1E8CB-4F45-4184-86359145767C29DE" ) return "org.lucee:hibernate-extension:" & q.version;
		}
		throw( message="hibernate extension [FAD1E8CB-4F45-4184-86359145767C29DE] not found via extensionList()" );
	}

	function run( testResults, testBox ) {

		describe( "Hibernate version string", function() {

			it( "should match the hibernate-core jar version", function() {
				var versionClass = createObject( "java", "org.hibernate.Version", { maven: [ hibernateArtifact() ] } );
				var reportedVersion = versionClass.getVersionString();
				var jarVersion = versionClass.getClass().getPackage().getImplementationVersion();
				systemOutput( "Hibernate reported: #reportedVersion#, jar manifest: #( jarVersion ?: 'null' )#", true );
				expect( reportedVersion ).notToBe( "[WORKING]",
					"Version.getVersionString() must not return [WORKING] - the hibernate-core jar manifest must carry Implementation-Version" );
				expect( reportedVersion ).toBe( jarVersion,
					"Version.getVersionString() should match the Implementation-Version from the jar manifest" );
			});

		});

	}

}
