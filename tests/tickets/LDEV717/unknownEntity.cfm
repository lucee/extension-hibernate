<cfscript>
	try {
		entityNew( "DoesNotExist" );
	}
	catch ( any e ) {
		echo( e.message );
		abort;
	}
	throw "entityNew() with an unknown entity name did not throw";
</cfscript>
