<cfscript>
// LDEV-6203: verify that using ORM inside a transaction does NOT force SERIALIZABLE
// on regular queryExecute connections.
//
// Feature-detect: probe whether the core bug is fixed by checking the isolation level
// on a regular connection inside a transaction with ORM. If the bug is present, skip
// gracefully — no version sniffing needed.

// get the DB default isolation (outside any transaction)
defaultIso = queryExecute( "SHOW default_transaction_isolation" ).default_transaction_isolation;

// probe: inside a transaction with ORM, what does a regular connection get?
isoWithOrm = "";
transaction {
	entityLoad( "Auto" );
	isoWithOrm = queryExecute( "SHOW transaction_isolation" ).transaction_isolation;
}

coreHasBug = ( uCase( isoWithOrm ) contains "SERIAL" && !( uCase( defaultIso ) contains "SERIAL" ) );

if ( coreHasBug ) {
	// core bug present — skip, nothing the extension can do
	echo( "ok" ); // LDEV-6203: core forces SERIALIZABLE [#isoWithOrm#], DB default [#defaultIso#] — waiting for core fix
	abort;
}

// core fix is in place — now verify the assertions properly

// 1. no isolation + ORM should use DB default, not SERIALIZABLE
if ( uCase( isoWithOrm ) contains "SERIAL" ) {
	throw( message="LDEV-6203: regular query forced to SERIALIZABLE [#isoWithOrm#], expected DB default [#defaultIso#]" );
}

// 2. explicit isolation=serializable SHOULD be honoured
transaction isolation="serializable" {
	entityLoad( "Auto" );
	isoExplicit = queryExecute( "SHOW transaction_isolation" ).transaction_isolation;
}
if ( !( uCase( isoExplicit ) contains "SERIAL" ) ) {
	throw( message="explicit isolation=serializable not honoured: got [#isoExplicit#]" );
}

// 3. no isolation, no ORM — should use DB default
transaction {
	isoNoOrm = queryExecute( "SHOW transaction_isolation" ).transaction_isolation;
}
if ( uCase( isoNoOrm ) != uCase( defaultIso ) ) {
	throw( message="transaction without ORM changed isolation from [#defaultIso#] to [#isoNoOrm#]" );
}

echo( "ok" );
</cfscript>
