component {

	this.name = "orm-ormconfig";
	this.datasources["h2"] = server.getDatasource("h2", "#getDirectoryFromPath(getCurrentTemplatePath())#/datasource/db" );
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		dialect: "h2",
		skipCFCWithError : false,
        datasource : "h2",
		ormConfig : "hibernate.cfg.xml"
	};

	function onApplicationStart() {
	}

	public function onRequestStart() {
		setting requesttimeout=10;
		if ( url.keyExists( "flushcache" ) ){
			componentCacheClear();
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