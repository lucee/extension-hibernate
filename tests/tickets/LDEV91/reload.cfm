<cfscript>
	ormReload();
	entitySave( entityNew( "Entity", { name: "b", createdBy: "lucee" } ) );
	ormFlush();
	if ( arrayLen( entityLoad( "Entity", { name: "b" } ) ) != 1 ) throw "entity [b] not found after ormReload()";
	echo( "ok" );
</cfscript>
