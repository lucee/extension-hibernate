<cfsetting showdebugoutput="false">
<cfscript>
	code = entityNew( 'Code' );
	code.setId( 1 );
	code.setCode( 'a' );
	// should trigger preInsert, postInsert, and onFlush
	entitySave( code );
// should trigger onFlush event
	ormFlush();
    ormClearSession();
    result = {
		events: [],
		errors: []
	};

	loop array=application.ormEventLog item="a" {
		arrayAppend(result.events, a.eventName);
	};

	loop array=application.ormEventErrorLog item="a" {
		arrayAppend(result.errors, a);
	};
	echo( result.toJson() );
</cfscript>
