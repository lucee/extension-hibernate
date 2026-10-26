<cfscript>
	ormReload();
	entitySave( entityNew( "Person", { name: "lucee" } ) );
	entitySave( entityNew( "Person", { name: "railo" } ) );
	entitySave( entityNew( "Animal", { name: "lucee" } ) );
	ormFlush();
	ormClearSession();
	switch ( url.scene ) {
		case "single":
			q = entityToQuery( entityLoad( "Person", { name: "lucee" }, true ) );
			break;
		case "array":
			q = entityToQuery( entityLoad( "Person", {}, "name" ) );
			break;
		case "transient":
			q = entityToQuery( entityLoad( "Animal", { name: "lucee" }, true ) );
			break;
	}
	echo( listSort( q.columnList, "textnocase" ) & "|" & q.recordcount & "|" & valueList( q.name ) );
</cfscript>
