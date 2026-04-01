<cfsetting showdebugoutput="false">
<cfscript>
	person = entityNew( 'Person' );
    person.setPerson( "ralio" );  // preInsert handler updates this to Lucee
    entitySave(person);

    ormFlush();
	// trigger onClear
	ormClearSession();
	result = {
		events: [],
		errors: [],
        person: entityLoadByPK("Person", 1).getPerson()
	};

	loop array=application.ormEventLog item="a" {
		arrayAppend(result.events, a.eventName);
	};

	loop array=application.ormEventErrorLog item="a" {
		arrayAppend(result.errors, a);
	};
	echo( result.toJson() );
</cfscript>
