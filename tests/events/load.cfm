<cfsetting showdebugoutput="false">
<cfscript>
	code = entityNew( 'Code' );
	code.setId( 100 );
	code.setCode( 'a' );
	// should trigger preInsert, postInsert, and onFlush
	entitySave( code );
	ormFlush();

	ormClearSession();
	arr = entityLoad( "Code", 100 );
	
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
