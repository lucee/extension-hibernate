<cfsetting showdebugoutput="false">
<cfscript>
	code = entityNew( 'Code' );
	arr = entityLoad("Code");
	ormFlush();
	// trigger onClear
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
