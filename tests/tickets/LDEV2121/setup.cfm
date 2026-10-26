<cfscript>
	ormReload();
	entitySave( entityNew( "Composite", { k1: 1, k2: "a", name: "first" } ) );
	entitySave( entityNew( "Composite", { k1: 1, k2: "b", name: "second" } ) );
	ormFlush();
	ormClearSession();
</cfscript>
