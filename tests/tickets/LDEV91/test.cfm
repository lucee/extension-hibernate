<cfscript>
	entitySave( entityNew( "Entity", { name: "a", createdBy: "lucee" } ) );
	ormFlush();
	ormClearSession();
	loaded = entityLoad( "Entity", {}, true );
	if ( loaded.getName() != "a" ) throw "name is [#loaded.getName()#], expected [a]";
	if ( loaded.getCreatedBy() != "lucee" ) throw "createdBy is [#loaded.getCreatedBy()#], expected [lucee]";
	echo( "ok" );
</cfscript>
