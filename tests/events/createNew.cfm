<cfsetting showdebugoutput="false">
<cfscript>
	code = entityNew( 'Code' );
	code.setId( 1 );
	code.setCode( 'a' );
	// trigger preInsert and postInsert
	entitySave( code );
	// trigger onFlush
	ormFlush();
	// trigger onClear
    ormClearSession();
    result = {
		events: [],
		errors: []
	};

	loop array=application.ormEventLog item="a" {
		arrayAppend(result.events, "#a.src#.#a.eventName#");
	};

	loop array=application.ormEventErrorLog item="a" {
		arrayAppend(result.errors, a);
	};
	echo( result.toJson() );
</cfscript>
