<cfscript>
	person = entityNew( "Person4067Init" );
	result = {
		newInitCalled: person.initCalled,
		newStatus: person.getStatus()
	};
	person.setId( "init-1" );
	person.setName( "Michael" );
	person.setStatus( "archived" );
	entitySave( person );
	ormFlush();
	ormClearSession();

	loaded = entityLoadByPK( "Person4067Init", "init-1" );
	result.loadedInitCalled = loaded.initCalled;
	result.loadedStatus = loaded.getStatus();
	result.loadedName = loaded.getName();
	result.loadedClosure = loaded.getNameFn();
	echo( serializeJSON( result ) );
</cfscript>
