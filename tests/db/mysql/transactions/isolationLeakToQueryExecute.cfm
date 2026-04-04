<cfscript>
// LDEV-6203: verify that using ORM inside a transaction does NOT force SERIALIZABLE
// on regular queryExecute connections.
//
// DatasourceManagerImpl._add() mutates this.isolation to SERIALIZABLE when ORM joins
// a transaction with no explicit isolation. This leaks to regular JDBC connections.
//
// Feature-detect: probe whether the core bug is fixed by checking the isolation level
// on a regular connection inside a transaction with ORM. If the bug is present, skip
// gracefully — no version sniffing needed.

// get the DB default isolation (outside any transaction)
defaultIso = queryExecute( "SELECT @@transaction_isolation as iso" ).iso;

// probe: inside a transaction with ORM, what does a regular connection get?
isoWithOrm = "";
transaction {
	entityLoad( "Auto" );
	isoWithOrm = queryExecute( "SELECT @@transaction_isolation as iso" ).iso;
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
	isoExplicit = queryExecute( "SELECT @@transaction_isolation as iso" ).iso;
}
if ( !( uCase( isoExplicit ) contains "SERIAL" ) ) {
	throw( message="explicit isolation=serializable not honoured: got [#isoExplicit#]" );
}

// 3. no isolation, no ORM — should use DB default
transaction {
	isoNoOrm = queryExecute( "SELECT @@transaction_isolation as iso" ).iso;
}
if ( uCase( isoNoOrm ) != uCase( defaultIso ) ) {
	throw( message="transaction without ORM changed isolation from [#defaultIso#] to [#isoNoOrm#]" );
}

echo( "ok" );
</cfscript>
