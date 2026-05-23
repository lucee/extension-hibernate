<cfscript>
// Characterisation test for the OSGi dialect scan in Dialect.java.
// Goal: snapshot what gets registered so we can diff scan-on vs scan-off and decide
// whether the static-init scan adds anything the hardcoded `dialects.setEL(...)` list
// doesn't. See LDEV-6342.
//
// What this test answers:
//   1. Are dialects actually registered?
//   2. Does every registered key resolve via getDialect(name)?
//   3. Do common short names (MySQL, Oracle, H2, ...) resolve?
//   4. Do FQCN lookups (org.hibernate.dialect.MySQLDialect) resolve? — scan-only alias
//   5. Do simple-class-name lookups (MySQLDialect) resolve? — scan-only alias
//
// Run with the scan enabled, capture output. Then comment out the static { ... } scan
// block in Dialect.java, rerun. Diff the output. Any short-name dialects that disappear
// were only registered by the scan and need to be added to the hardcoded list (or
// declared unsupported). FQCN / simple-class lookups disappearing tells you whether
// anyone actually relies on those alias forms.
try {
	dialectClass = createObject( "java", "org.lucee.extension.orm.hibernate.Dialect" );
	dialects = dialectClass.getDialects();
	keys = structKeyArray( dialects );
	arraySort( keys, "textnocase" );

	systemOutput( "", true );
	systemOutput( "=== Dialect registry snapshot (total: #arrayLen( keys )#) ===", true );
	for ( k in keys ) {
		systemOutput( k & " -> " & dialects[ k ], true );
	}
	systemOutput( "=== end dialect registry snapshot ===", true );

	// Sanity: every registered key must resolve via the public lookup.
	unresolvable = [];
	for ( k in keys ) {
		resolved = dialectClass.getDialect( javaCast( "string", k ) );
		if ( isNull( resolved ) || len( resolved ) == 0 )
			arrayAppend( unresolvable, k );
	}
	if ( arrayLen( unresolvable ) )
		throw( message="Dialects registered but unresolvable via getDialect(): [#arrayToList( unresolvable, ', ' )#]" );

	// Common short names users actually pass via ormSettings.dialect. These should
	// always resolve — they come from the hardcoded list, not the scan.
	commonShort = [ "MySQL", "MySQL55", "MySQL57", "Oracle", "Oracle12c", "H2", "HSQL",
		"PostgreSQL", "PostgreSQL95", "MariaDB", "MariaDB103", "DB2", "Sybase", "SQLServer" ];
	missingShort = [];
	for ( name in commonShort ) {
		if ( isNull( dialectClass.getDialect( javaCast( "string", name ) ) ) )
			arrayAppend( missingShort, name );
	}

	// FQCN — scan-only alias. Comment out the scan and these will fail.
	fqcnSamples = [
		"org.hibernate.dialect.MySQLDialect",
		"org.hibernate.dialect.OracleDialect",
		"org.hibernate.dialect.H2Dialect",
		"org.hibernate.dialect.PostgreSQLDialect"
	];
	missingFQCN = [];
	for ( name in fqcnSamples ) {
		if ( isNull( dialectClass.getDialect( javaCast( "string", name ) ) ) )
			arrayAppend( missingFQCN, name );
	}

	// Simple class name — scan-only alias. Comment out the scan and these will fail.
	simpleClassSamples = [ "MySQLDialect", "OracleDialect", "H2Dialect", "PostgreSQLDialect" ];
	missingSimpleClass = [];
	for ( name in simpleClassSamples ) {
		if ( isNull( dialectClass.getDialect( javaCast( "string", name ) ) ) )
			arrayAppend( missingSimpleClass, name );
	}

	systemOutput( "", true );
	systemOutput( "=== alias resolution ===", true );
	systemOutput( "common short names (hardcoded list expected): missing=[#arrayToList( missingShort, ', ' )#]", true );
	systemOutput( "FQCN samples (scan-only expected): missing=[#arrayToList( missingFQCN, ', ' )#]", true );
	systemOutput( "simple class samples (scan-only expected): missing=[#arrayToList( missingSimpleClass, ', ' )#]", true );
	systemOutput( "=== end alias resolution ===", true );

	// Hard assertion: common short names MUST resolve regardless of scan state. The
	// hardcoded list is the contract. If any of these fail, either the hardcoded
	// list is missing entries or the createObject failed.
	if ( arrayLen( missingShort ) )
		throw( message="Common dialect short names did not resolve: [#arrayToList( missingShort, ', ' )#]" );

	echo( "ok" );
}
catch ( any e ) {
	systemOutput( "probe failed: " & e.message, true );
	if ( !isNull( e.stacktrace ) ) systemOutput( e.stacktrace, true );
	echo( e.message );
}
</cfscript>
