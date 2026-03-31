<cfscript>
// OOE-12: preInsert does NOT touch username, so null username should still throw
theUser = entityNew( "User", { id: createUUID(), name: "Julian" } );
threw = false;
try {
	entitySave( theUser );
	ormFlush();
} catch ( any e ) {
	threw = true;
}
ormEvictEntity( "User" );
ormClearSession();

if ( !threw ) throw( message="expected constraint violation for null username" );

echo( "ok" );
</cfscript>
