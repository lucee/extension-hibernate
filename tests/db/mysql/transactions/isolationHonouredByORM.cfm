<cfscript>
// LDEV-6205: verify that cftransaction isolation= is applied to the ORM JDBC connection,
// not just regular queryExecute connections.

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

// 2. explicit isolation=read_uncommitted — ORM connection should see read_uncommitted
ormIso2 = "";
transaction isolation="read_uncommitted" {
	entityLoad( "Auto" );
	ormIso2 = GetORMTransactionIsolation();
}
if ( ormIso2 != "read_uncommitted" ) {
	throw( message="LDEV-6205: ORM connection isolation should be [read_uncommitted], got [#ormIso2#]" );
}

// 3. no explicit isolation — ORM connection should use DB default (not forced to serializable)
ormIso3 = "";
transaction {
	entityLoad( "Auto" );
	ormIso3 = GetORMTransactionIsolation();
}
if ( len( ormIso3 ) == 0 ) {
	throw( message="LDEV-6205: ORM connection isolation should not be empty inside a transaction" );
}

// 4. after transaction ends, verify isolation is reset (check via ORM in a new transaction)
transaction {
	entityLoad( "Auto" );
	afterIso = GetORMTransactionIsolation();
}
if ( afterIso != ormIso3 ) {
	throw( message="LDEV-6205: isolation not reset after transaction, expected default [#ormIso3#], got [#afterIso#]" );
}

echo( "ok" );
</cfscript>
