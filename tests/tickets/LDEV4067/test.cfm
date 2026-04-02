<cfscript>
	// matches the exact reproduction from LDEV-4067
	person = entityNew( "Person4067" );
	person.setId( "test-4067" );
	person.setName( "Michael" );
	entitySave( person );
	ormFlush();
	ormClearSession();

	loaded = entityLoadByPK( "Person4067", "test-4067" );
	echo( loaded.memento.mappers[ "theName" ]() );
</cfscript>
