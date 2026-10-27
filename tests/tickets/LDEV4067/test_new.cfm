<cfscript>
	// closure on a fresh entityNew() instance, never persisted or loaded
	person = entityNew( "Person4067" );
	person.setName( "Michael" );
	echo( person.memento.mappers[ "theName" ]() );
</cfscript>
