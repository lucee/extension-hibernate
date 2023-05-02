component {

	this.name = "orm-dialects";
	this.datasources["h2"] = server.getDatasource("h2", "#getDirectoryFromPath(getCurrentTemplatePath())#/datasource/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		cfclocation     : [ "entities" ],
		dbcreate        : "dropcreate",
		skipCFCWithError: false,
		datasource      : "h2",
	};
	rootPath = REReplaceNoCase(
		getDirectoryFromPath( getCurrentTemplatePath() )
		, "builtins(\\|/)", ""
	);
	this.mappings[ "/testbox" ] = rootPath & "testbox";

	function onApplicationStart() {
	}

	public function onRequestStart() {
		setting requesttimeout=10;
		if ( url.keyExists( "flushcache" ) ){
			componentCacheClear();
		}
		if ( url.keyExists( "reinitApp" ) ){
			applicationStop();
		}
	}

	function onRequestEnd() {
		var javaIoFile=createObject("java","java.io.File");
		loop array = DirectoryList(
				path = getDirectoryFromPath( getCurrentTemplatePath() ), 
				recurse = true, filter="*.db") item="local.path"  {
			fileDeleteOnExit(javaIoFile,path);
		}
	}

	private function fileDeleteOnExit(required javaIoFile, required string path) {
		var file=javaIoFile.init(arguments.path);
		if(!file.isFile())file=javaIoFile.init(expandPath(arguments.path));
		if(file.isFile()) file.deleteOnExit();
	}

}