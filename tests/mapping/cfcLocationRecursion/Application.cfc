component {
	withMapping = structKeyExists( url, "withMapping" ) && url.withMapping;
	this.name = "test-cfclocation-recursion-#hash( getCurrentTemplatePath() & withMapping )#";
	this.datasource = server.getDatasource( "h2", server._getTempDir( "orm-cfclocation-recursion-#withMapping#" ) );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		// Parent's recursive cfclocation walks into ./child/entities/ and picks up
		// Foo.cfc + Bar.cfc, even though child/Application.cfc owns that dir.
		// Foo declares cfc="childns.Bar" — without the matching this.mappings entry
		// in this parent app, that ref is unresolvable and the SF build correctly
		// throws (see cfcLocationRecursion.cfc — first spec).
		// When the spec passes url.withMapping=true, this app declares the matching
		// /childns mapping below and the same setup resolves successfully.
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
	if ( withMapping ) {
		this.mappings = { "/childns" = getDirectoryFromPath( getCurrentTemplatePath() ) & "child/entities" };
	}
}
