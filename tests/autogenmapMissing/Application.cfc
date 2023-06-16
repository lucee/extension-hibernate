component displayname="Application" output="false" {
	this.name = "autogenmap-missing-LDEV-3525-#url.autogenmap#";
	this.sessionManagement = true;
	this.setClientCookies = true;
	this.setDomainCookies = false;
	this.sessionTimeOut = CreateTimeSpan(0,1,0,0);
	this.applicationTimeOut = CreateTimeSpan(1,0,0,0);
	this.datasource = server.getDatasource("h2", server._getTempDir( "LDEV-3525" ) );

	this.ormenabled = true;
	this.ormSettings.savemapping = true;
	this.ormSettings.autogenmap = url.autogenmap;

	if ( url.autogenmap )
		this.ormSettings.dbcreate = "dropcreate";
}