component {
	this.name = "test-cacheConfig-#hash( getCurrentTemplatePath() )#";
	this.datasources["h2"] = server.getDatasource( "h2", "#getDirectoryFromPath( getCurrentTemplatePath() )#/datasource/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2",
		datasource: "h2",
		secondarycacheenabled: true,
		cacheprovider: "ehcache",
		cacheconfig: "ehcache.xml",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};

	public function onRequestStart() {
		setting requesttimeout=10;
	}

	function onRequestEnd() {
		var javaIoFile = createObject( "java", "java.io.File" );
		loop array=DirectoryList(
			path=getDirectoryFromPath( getCurrentTemplatePath() ),
			recurse=true, filter="*.db" ) item="local.path" {
			var file = javaIoFile.init( local.path );
			if ( file.isFile() ) file.deleteOnExit();
		}
	}
}
