<cfscript>
// LDEV-6205: verify that cftransaction isolation= is applied to the ORM JDBC connection.
// PostgreSQL version.

// Feature-detect: the extension reads isolation via DatasourceManagerImpl.getIsolation()
// which only exists on Lucee 7.1+. On older versions isolation is not applied (no-op).
try {
	getPageContext().getDataSourceManager().getIsolation();
}
catch ( any e ) {
	systemOutput( "LDEV-6205 SKIP: DatasourceManagerImpl.getIsolation() not available (needs Lucee 7.1+)", true );
	echo( "ok" );
	abort;
}

// 1. explicit isolation=serializable — ORM connection should see serializable
ormIso = "";
transaction isolation="serializable" {
	entityLoad( "Auto" ); // ensure ORM session joins transaction
	ormIso = GetORMTransactionIsolation();
}
if ( ormIso != "serializable" ) {
	throw( message="LDEV-6205: ORM connection isolation should be [serializable], got [#ormIso#]" );
}

// 2. explicit isolation=read_uncommitted — PostgreSQL JDBC driver may report read_uncommitted or read_committed
ormIso2 = "";
transaction isolation="read_uncommitted" {
	entityLoad( "Auto" );
	ormIso2 = GetORMTransactionIsolation();
}
if ( ormIso2 != "read_uncommitted" && ormIso2 != "read_committed" ) {
	throw( message="LDEV-6205: ORM connection isolation should be [read_uncommitted] or [read_committed], got [#ormIso2#]" );
}

// 3. no explicit isolation — ORM connection should use DB default
ormIso3 = "";
transaction {
	entityLoad( "Auto" );
	ormIso3 = GetORMTransactionIsolation();
}
if ( len( ormIso3 ) == 0 ) {
	throw( message="LDEV-6205: ORM connection isolation should not be empty inside a transaction" );
}

echo( "ok" );
</cfscript>
