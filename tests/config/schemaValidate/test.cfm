<cfscript>
// First request with dbcreate=dropcreate creates the table.
// This test just verifies the entity works — the real validate test
// would need a second Application.cfc with dbcreate=validate and a mismatched entity.
// For now, verify basic validate-compatible round-trip.
id = createUUID();
entity = entityNew( "ValidateEntity", { id: id, name: "Test" } );
entitySave( entity );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "ValidateEntity", id );
if ( loaded.getName() != "Test" )
	throw( message="expected Test, got #loaded.getName()#" );

echo( "ok" );
</cfscript>
