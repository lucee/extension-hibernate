<cfscript>
// Entity name `customer` (wrong case) against entity `Customer` —
// H7.3+ strict parser rejects with "Could not resolve root entity".
try {
	ormExecuteQuery( "from customer" );
	echo( "ok" );
} catch( any e ) {
	echo( e.message );
}
</cfscript>
