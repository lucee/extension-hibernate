<cfscript>
// Create two rows to fight over
item1 = entityNew( "Item", { id: "A", name: "item-a", value: 1 } );
item2 = entityNew( "Item", { id: "B", name: "item-b", value: 1 } );
entitySave( item1 );
entitySave( item2 );
ormFlush();
ormClearSession();

// Thread 1: update A then B
// Thread 2: update B then A
// Classic deadlock pattern — opposite lock acquisition order

thread name="t1" action="run" {
	try {
		transaction {
			var a = entityLoadByPK( "Item", "A", true );
			a.setValue( a.getValue() + 1 );
			entitySave( a );
			ormFlush();
			// small delay to let t2 grab its first lock
			sleep( 200 );
			var b = entityLoadByPK( "Item", "B", true );
			b.setValue( b.getValue() + 1 );
			entitySave( b );
			ormFlush();
		}
		thread.result = "committed";
		thread.errorMsg = "";
	} catch( any e ) {
		thread.result = "error";
		thread.errorMsg = e.message;
		thread.errorDetail = structKeyExists( e, "detail" ) ? e.detail : "";
		thread.errorType = structKeyExists( e, "type" ) ? e.type : "";
		systemOutput( serializeJson( var=e, compact=false ), true );
	}
}

thread name="t2" action="run" {
	try {
		transaction {
			var b = entityLoadByPK( "Item", "B", true );
			b.setValue( b.getValue() + 1 );
			entitySave( b );
			ormFlush();
			sleep( 200 );
			var a = entityLoadByPK( "Item", "A", true );
			a.setValue( a.getValue() + 1 );
			entitySave( a );
			ormFlush();
		}
		thread.result = "committed";
		thread.errorMsg = "";
	} catch( any e ) {
		thread.result = "error";
		thread.errorMsg = e.message;
		thread.errorDetail = structKeyExists( e, "detail" ) ? e.detail : "";
		thread.errorType = structKeyExists( e, "type" ) ? e.type : "";
		systemOutput( serializeJson( var=e, compact=false ), true );
	}
}

thread action="join" name="t1,t2" timeout="30000";

// At least one thread should error with a deadlock
t1 = cfthread[ "t1" ];
t2 = cfthread[ "t2" ];

// Collect the error message from whichever thread got the deadlock
deadlockMsg = "";
deadlockDetail = "";
deadlockType = "";
deadlockStacktrace = "";
if ( t1.result == "error" ) {
	deadlockMsg = t1.errorMsg;
	deadlockDetail = t1.errorDetail;
	deadlockType = t1.errorType;
	deadlockStacktrace = t1.stacktrace;
} else if ( t2.result == "error" ) {
	deadlockMsg = t2.errorMsg;
	deadlockDetail = t2.errorDetail;
	deadlockType = t2.errorType;
	deadlockStacktrace = t2.stacktrace;
}

// Output for the test to inspect
echo( "t1=#t1.result#" & chr( 10 ) );
echo( "t2=#t2.result#" & chr( 10 ) );
echo( "msg=#deadlockMsg#" & chr( 10 ) );
echo( "detail=#deadlockDetail#" & chr( 10 ) );
echo( "type=#deadlockType#" & chr( 10 ) );

// dump to console
systemOutput( "DEADLOCK TEST: t1=#t1.result# t2=#t2.result#", true );
</cfscript>
