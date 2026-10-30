<cfscript>
// HQL property `username` (wrong case) against CFC property `UserName` —
// H7.3+ strict parser rejects with "Could not interpret path expression".
try {
	ormExecuteQuery( "from Customer where username = :n", { n: "JohnSmith" } );
	echo( "ok" );
} catch( any e ) {
	echo( e.message );
}
</cfscript>
