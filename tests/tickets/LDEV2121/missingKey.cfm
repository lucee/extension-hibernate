<cfscript>
	include "setup.cfm";
	try {
		entityLoadByPK( "Composite", { k1: 1 } );
		echo( "no error" );
	}
	catch ( any e ) {
		echo( e.message );
	}
</cfscript>
