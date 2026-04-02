<cfscript>
// LDEV-119: ORMReload() under concurrent load should not cause NPE or leak connections
// Seed some data so reader threads have something to query
for ( i = 1; i <= 10; i++ ) {
	entitySave( entityNew( "LDEV119Entity", { id: createUUID(), name: "seed-#i#" } ) );
}
ormFlush();

threadNames = [];

// Start reader threads that continuously query ORM
for ( i = 1; i <= 5; i++ ) {
	tName = "reader#i#";
	threadNames.append( tName );
	thread name="#tName#" {
		for ( j = 1; j <= 20; j++ ) {
			try {
				entities = entityLoad( "LDEV119Entity" );
				entitySave( entityNew( "LDEV119Entity", { id: createUUID(), name: "thread-#thread.name#-#j#" } ) );
				ormFlush();
			}
			catch ( any e ) {
				thread.error = e;
				break;
			}
		}
	}
}

// Give readers a moment to start, then reload ORM
sleep( 50 );
for ( r = 1; r <= 3; r++ ) {
	ormReload();
	sleep( 20 );
}

thread action="join" name="#arrayToList( threadNames )#" timeout="30000";

// Collect results — NPEs are the bug, other errors during reload are tolerable
npeCount = 0;
npeDetails = [];
for ( tName in threadNames ) {
	if ( structKeyExists( cfthread[ tName ], "error" ) ) {
		err = cfthread[ tName ].error;
		msg = err.message ?: "";
		stack = err.stacktrace ?: "";
		if ( findNoCase( "NullPointerException", msg ) || findNoCase( "NullPointerException", stack ) ) {
			npeCount++;
			npeDetails.append( "[#tName#] #msg# --- #stack#" );
			systemOutput(stack, true);
		}
	}
}

if ( npeCount > 0 ) {
	throw( message="ORMReload caused #npeCount# NullPointerException(s) in concurrent threads: #chr(10)##arrayToList( npeDetails, chr(10) )#" );
}

echo( "ok" );
</cfscript>
