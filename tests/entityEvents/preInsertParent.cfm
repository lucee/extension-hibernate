<cfscript>
// OOE-14: preInsert can mutate property on parent entity (Admin extends User)
theAdmin = entityNew( "Admin", {
	id: createUUID(), name: "Julian", username: "jwell"
} );
entitySave( theAdmin );
// preInsert on parent User should detect null password and set it
ormFlush();

ormEvictEntity( "Admin" );
ormClearSession();

echo( "ok" );
</cfscript>
