<cfscript>
// Baseline: ORM operations outside a transaction block should auto-commit.
// This is the current behaviour and should NOT change with the facade fix.
// The facade fix only affects code inside transaction{} blocks.

id = createUUID();

// no transaction block — entitySave + ormFlush should auto-commit
entitySave( entityNew( "Auto", { id: id, make: "Subaru", model: "BRZ" } ) );
ormFlush();

result = queryExecute( "SELECT * FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 )
	throw( message="expected 1 row after entitySave outside transaction, got #result.recordCount#" );

echo( "ok" );
</cfscript>
