<cfscript>
// LDEV-6207: test isWithinORMTransaction() BIF

// 1. outside any transaction — should be false
if ( isWithinORMTransaction() )
	throw( message="isWithinORMTransaction() returned true outside any transaction" );

// 2. inside a cftransaction with ORM — should be true
inTxResult = false;
transaction {
	entityLoad( "Auto" );
	inTxResult = isWithinORMTransaction();
}

if ( !inTxResult )
	throw( message="isWithinORMTransaction() returned false inside cftransaction with ORM — Hibernate transaction not active" );

// 3. after transaction ends — should be false
if ( isWithinORMTransaction() )
	throw( message="isWithinORMTransaction() returned true after transaction ended" );

echo( "ok" );
</cfscript>
