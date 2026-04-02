<cfscript>
	// simpler case: closure as a direct data member (not nested in a struct)
	person = entityNew( "Person4067Direct" );
	person.setId( "test-4067d" );
	person.setName( "Michael" );
	entitySave( person );
	ormFlush();
	ormClearSession();

	loaded = entityLoadByPK( "Person4067Direct", "test-4067d" );
	echo( loaded.getNameFn() );
</cfscript>
