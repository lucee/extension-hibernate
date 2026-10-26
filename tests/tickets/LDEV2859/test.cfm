<cfscript>
	ormReload();
	entitySave( entityNew( "Person", { name: "lucee" } ) );
	entitySave( entityNew( "Person", { name: "railo" } ) );
	ormFlush();
	ormClearSession();
	persons = entityLoad( "Person", {}, "name" );
	switch ( url.scene ) {
		case "array":
			q = entityToQuery( persons, "Person" );
			break;
		case "single":
			q = entityToQuery( persons[ 1 ], "Person" );
			break;
		case "case":
			q = entityToQuery( persons, "PERSON" );
			break;
	}
	echo( q.recordcount & ":" & valueList( q.name ) );
</cfscript>
