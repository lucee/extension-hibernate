<cfscript>
// LDEV-6206: Hibernate transaction must be ACTIVE inside a cftransaction block.

id = createUUID();

hibernateTxStatus = "";

transaction {
	entitySave( entityNew( "Auto", { id: id, make: "Proof", model: "Concept" } ) );
	ormFlush();

	rawSession = ormGetSession();
	hibernateTxStatus = rawSession.getTransaction().getStatus().toString();
}

// clean up
queryExecute( "DELETE FROM Auto WHERE id = :id", { id: id } );

if ( hibernateTxStatus != "ACTIVE" )
	throw( message="Hibernate transaction status is [#hibernateTxStatus#] inside cftransaction, should be [ACTIVE]" );

echo( "ok" );
</cfscript>
