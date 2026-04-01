<cfscript>
// OOE-12: preInsert can auto-set a notnull field (password), preventing constraint violation
theUser = entityNew( "User", {
	id: createUUID(), name: "Julian", username: "jwell"
} );
entitySave( theUser );
// preInsert should detect null password and set it — no constraint violation
ormFlush();

ormEvictEntity( "User" );
ormClearSession();

echo( "ok" );
</cfscript>
