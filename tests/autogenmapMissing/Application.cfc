<cfcomponent displayname="Application" output="false">

	<cfset this.name = "autogenmap-missing-LDEV-3525">
	<cfset this.sessionManagement = true />
	<cfset this.setClientCookies = true />
	<cfset this.setDomainCookies = false />
	<cfset this.sessionTimeOut = CreateTimeSpan(0,1,0,0) />
	<cfset this.applicationTimeOut = CreateTimeSpan(1,0,0,0) />
	<cfset this.datasource = server.getDatasource("h2", server._getTempDir( "LDEV-3525" ) ) />

	<cfset this.ormenabled = true />
	<cfset this.ormSettings.savemapping = true />
	<cfset this.ormSettings.autogenmap = false />
</cfcomponent>