<cfscript>
// OOE-14: preUpdate can mutate property on parent entity (Admin extends User)
theAdmin = entityNew( "Admin", {
	id: createUUID(), name: "Julian", username: "jwell", password: "CF4Life"
} );
entitySave( theAdmin );
ormFlush();
entityReload( theAdmin );

theAdmin.setPassword( javaCast( "null", "" ) );
entitySave( theAdmin );
// preUpdate on parent User should detect null password and set it
ormFlush();

ormEvictEntity( "Admin" );
ormClearSession();

echo( "ok" );
</cfscript>
