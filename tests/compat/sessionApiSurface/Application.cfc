component {
	this.name = "session-api-surface";
	this.datasource = {
		class: "org.h2.Driver",
		bundleName: "org.lucee.h2",
		connectionString: "jdbc:h2:mem:sessionApiSurface;MODE=MySQL"
	};
	this.ormEnabled = true;
	this.ormSettings = {
		dbcreate: "dropcreate",
		cfclocation: [ getDirectoryFromPath( getCurrentTemplatePath() ) ]
	};
}
